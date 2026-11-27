import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { ConfigStore } from '../config/ConfigStore';

@Entry
@Component
struct Index {
  @State configUrl: string = '';
  @State status: string = '请输入配置地址（与 TVBoxOS 的 api 配置一致）';
  @State siteCount: number = 0;
 private store: ConfigStore = ConfigStore.getInstance();

  async aboutToAppear(): Promise<void> {
    await this.store.init(this.getUIContext().getHostContext()!);
    this.configUrl = await this.store.getConfigUrl();
  }

  private async loadConfig(): Promise<void> {
    if (this.configUrl.length === 0) {
      this.status = '配置地址不能为空';
      return;
    }
    this.status = '正在拉取配置...';
    try {
      const req = http.createHttp();
      const res = await req.request(this.configUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      const text = res.result as string;
      const cfg = this.store.parseConfig(text);
      await this.store.setConfigUrl(this.configUrl);
      await this.store.saveRawConfig(text);
      this.siteCount = cfg.sites ? cfg.sites.length : 0;
      this.status = `配置加载成功，站点数：${this.siteCount}`;
      req.destroy();
    } catch (e) {
      const err = e as BusinessError;
      this.status = `配置加载失败：${err.code} ${err.message}`;
    }
  }

  build() {
    Column() {
      Text('TVBoxOS 鸿蒙移植 - 阶段 1 骨架')
        .fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 24 })
      TextInput({ placeholder: 'https://.../config.json', text: this.configUrl })
        .onChange((v: string) => { this.configUrl = v; })
        .width('90%')
      Button('导入配置').margin({ top: 16 }).onClick(() => { this.loadConfig(); })
      Button('进入首页').margin({ top: 8 }).onClick(() => { router.pushUrl({ url: 'pages/Home' }); })
      Text(this.status).margin({ top: 20 }).fontSize(16)
      Text('下一步：阶段 2 Spider 契约与 JS 爬虫运行时；阶段 3 AVPlayer 播放器')
        .margin({ top: 40 }).fontSize(12).fontColor(Color.Gray)
    }
    .width('100%').height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }
}
