# HMTV

HarmonyOS 7 (API 26) 原生重写版 TVBoxOS，目标设备 Mate 80。ArkTS + ArkUI，Stage 模型。

## 当前状态

- 阶段 1：配置导入 / 网络 / 持久化 / 首页骨架
- 阶段 2：Spider 契约 + ArkWeb JS 运行时 + HTTP JSON 源适配
- 阶段 3：AVPlayer 播放器 + 详情首播地址解析
- 阶段 4+：收藏历史、直播/EPG、投屏、弹幕字幕、多仓管理待实现

## 自动构建

GitHub Actions 使用华为 HarmonyOS Command Line Tools（通过 `wm-develop/setup-ohos` 安装官方命令行工具）执行：

```
ohpm install
hvigorw --mode module -p product=default -p buildMode=debug assembleHap --no-daemon --accept-license
```

构建产物 HAP 会作为 Artifact `hmtv-hap` 上传。CI 未配置签名，产物为 unsigned HAP，仅用于真机调试（需自行签名或使用 DevEco Studio 自动签名）。

## 本地构建

需要 DevEco Studio 26 / HarmonyOS 7 SDK：

```
ohpm install
hvigorw --mode module -p product=default assembleHap --no-daemon
```

## 目录

- `entry/src/main/ets/spider/`：Spider 契约、JS 运行时、HTTP 源适配
- `entry/src/main/ets/player/`：AVPlayer 封装
- `entry/src/main/resources/rawfile/spider/runner.html`：JS 爬虫容器与 cat.js 兼容层
- `docs/`：移植报告与阶段实现说明

## 许可证

AGPL-3.0，见 `LICENSE`。源项目：https://github.com/q215613905/TVBoxOS
