package crypto

import (
	"context"
	"strconv"
	"sync"
	"time"

	"github.com/uerax/goconf"
)

type Monitor struct {
	UserToCrypto sync.Map // key id value map[crypto]value
	CryptoToUser sync.Map // key crypto value map[user]value
	ctx	context.Context
	cancel context.CancelFunc
	api *Crypto
	notify map[int64]map[string]string
	notifyLog map[int64]map[string]int64
}

func NewCryptoMonitor() *Monitor {
	parent, done := context.WithCancel(context.Background())
	return &Monitor{
		UserToCrypto: sync.Map{},
		CryptoToUser: sync.Map{},
		ctx: parent,
		cancel: done,
		api: NewCrypto(goconf.VarStringOrDefault("", "crypto", "binance", "apiKey"),goconf.VarStringOrDefault("", "crypto", "binance", "secretKey")),
		notify: make(map[int64]map[string]string),
		notifyLog: make(map[int64]map[string]int64),
	}
	
}

func (t *Monitor) Add(id int64, crypto, price string) {
	utc, _ := t.UserToCrypto.LoadOrStore(id, make(map[string]string))
	utc.(map[string]string)[crypto+"USDT"] = price
	ctu, _ := t.CryptoToUser.LoadOrStore(crypto+"USDT", make(map[int64]string))
	ctu.(map[int64]string)[id] = price
	t.cancel()
	go t.Start()
}

func (t *Monitor) Start() {
	ticker := time.NewTicker(time.Minute)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
			keys := make([]string, 0, 10)
			t.CryptoToUser.Range(func(key, value any) bool {
				keys = append(keys, key.(string))
				return true
			})
			t.clearNotify()
			t.probe(keys)

        case <-t.ctx.Done():
            // 当收到ctx的完成信号时，停止探测
            return
        }
    }
}

func (t *Monitor) clearNotify() {
	t.notify = make(map[int64]map[string]string)
}

func (t *Monitor) probe(cryptos []string) {
	now := time.Now().Unix()
	m := t.api.Price(cryptos...)
	for k, v := range m {
		// k crypto v price
		curPrice, err := strconv.ParseFloat(v, 64)
		if err != nil {
			continue
		}
		val, ok := t.CryptoToUser.Load(k)
		if !ok {
			continue
		}
		for k1, v1 := range val.(map[int64]string) {
			// k user value price
			threshold, err := strconv.ParseFloat(v1, 64)
			if err != nil {
				continue
			}
			if curPrice >= threshold {
				if _, ok := t.notify[k1]; !ok {
					t.notify[k1] = make(map[string]string)
				}
				if _, ok := t.notifyLog[k1]; !ok {
					t.notifyLog[k1] = make(map[string]int64)
				}
				if last, ok := t.notifyLog[k1][k]; ok {
					if now - last >= 3600 {
						t.notify[k1][k] = v1
						t.notifyLog[k1][k] = now
					}
				} else {
					t.notify[k1][k] = v1
					t.notifyLog[k1][k] = now
				}
				
			}
		}
		
	}
}