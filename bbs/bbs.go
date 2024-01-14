package bbs

type BbsMonitor interface {
	Start()
	Stop()
	Monitor()
	GetStatus() string
}
