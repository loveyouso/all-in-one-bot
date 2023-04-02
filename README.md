## 一. Usage

在 all-in-one-bot.yml 添加你的 telegram token(从telegram的 @BotFather /newbot 获取)

## 二. Command List
### 1. 加密货币监控功能清单

__单位默认USDT,可在配置文件crypto -> unit修改__

- [x] add_crypto_growth_monitor 加密货币 提示价格 例: BNB 1110
- [x] add_crypto_decline_monitor 加密货币 提示价格 例: BNB 1110
- [x] get_crypto_price 加密货币[可选]
- [x] delete_crypto_minitor 加密货币(多个用逗号隔开) 例子: BNB,ARB

### 2. ChatGPT功能清单

- [x] chatgpt msg (如果在配置文件把chat设为true, 可以省略/chatgpt直接发送信息进行交互)

### 3. VPS库存监控功能清单

- [x] vps_monitor_supported_list 查看支持监控的网站
- [ ] vps_add_supported_list 添加支持监控的网站 例: url keyword name desc(有空格需要引号)
- [x] add_vps_monitor url(必须是vps_monitor_supported_list有的,或者系统站点模版的商家)

### 4. 抠图功能

- [x] 检测到图片直接抠图 (需要在配置文件将 photo -> enable 设为true并添加apikey)

## 三. Telegram Commands

__通过 @BotFather /setcommands 添加__

```
add_crypto_growth_monitor  - 添加加密货币高线监控 例: BNB 1.1 (单位USD)
add_crypto_decline_monitor  - 添加加密货币低线监控 例: BNB 1.1 (单位USD)
get_crypto_price - 查询当前价格(默认查询监控的加密货币) 例 : BNB
delete_crypto_minitor - 删除监控的加密货币 例: BNB,ARB
chatgpt - chatgpt功能
vps_monitor_supported_list - 查看支持监控的网站
add_vps_monitor - 添加VPS库存监控 例: URL(vps_monitor_supported_list里的)
vps_add_supported_list - 添加支持监控的网站 例: url keyword name desc(有空格需要引号)
```