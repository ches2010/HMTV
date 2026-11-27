import { router } from '@kit.ArkUI';
import { ConfigStore } from '../config/ConfigStore';
import { SiteBean } from '../model/SiteConfig';
import { VodItem, VodClass } from '../model/Vod';
import { VodParser } from '../model/VodParser';
import { SpiderFactory } from '../spider/SpiderFactory';
import { JsSpider } from '../spider/JsSpider';
import { SpiderRuntime } from '../spider/SpiderRuntime';
import { http } from '@kit.NetworkKit';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Home {
  @State sites: SiteBean[] = [];
 @State selected: number = 0;
  @State classes: VodClass[] = [];
  @State videos: VodItem[] = [];
 @State keyword: string = '';
 @State status: string = '';
  private store: ConfigStore = ConfigStore.getInstance();
  private runnerController: webview.WebviewController = SpiderRuntime.getInstance().controller;

 async aboutToAppear(): Promise<void> {
    await this.store.init(this.getUIContext().getHostContext()!);
    const cfg = this.store.parseConfig(await this.store.getRawConfig());
    this.sites = cfg.sites || [];
    if (this.sites.length > 0) this.loadHome();
 }

 private currentSite(): SiteBean | undefined {
    return this.sites.length > this.selected ? this.sites[this.selected] : undefined;
 }

 private async currentSpider() {
    const site = this.currentSite();
    if (!site) return undefined;
    const sp = SpiderFactory.create(site);
    if (sp instanceof JsSpider) {
      const req = http.createHttp();
      try {
        const res = await req.request(site.api, { expectDataType: http.HttpDataType.STRING });
        await sp.install(res.result as string);
      } finally { req.destroy(); }
    }
    return sp;
 }

 async loadHome(): Promise<void> {
    const sp = await this.currentSpider();
    if (!sp) return;
    this.status = '加载首页...';
    try {
      const json = await sp.homeContent(false);
      this.classes = VodParser.parseClasses(json);
      this.videos = VodParser.parseList(json).list;
      this.status = this.videos.length > 0 ? '已加载 ' + this.videos.length + ' 条' : '首页无数据，可尝试分类';
    } catch (e) {
      this.status = '加载失败：' + (e as Error).message;
    }
  }

 async loadCategory(tid: string): Promise<void> {
    const sp = await this.currentSpider();
    if (!sp) return;
    try {
      const json = await sp.categoryContent(tid, '1', false, new Map<string, string>());
      this.videos = VodParser.parseList(json).list;
      this.status = '分类 ' + tid + '：' + this.videos.length + ' 条';
    } catch (e) { this.status = '分类加载失败'; }
  }

 async search(): Promise<void> {
    const sp = await this.currentSpider();
    if (!sp) return;
    try {
      const json = await sp.searchContent(this.keyword, false, '1');
      this.videos = VodParser.parseList(json).list;
      this.status = '搜索结果：' + this.videos.length + ' 条';
    } catch (e) { this.status = '搜索失败'; }
  }

 async play(item: VodItem): Promise<void> {
    const sp = await this.currentSpider();
    if (!sp) return;
    try {
      const detail = await sp.detailContent([item.vod_id]);
      const info = VodParser.firstPlay(detail);
      if (!info) { this.status = '未解析到播放地址'; return; }
      router.pushUrl({
        url: 'pages/Player',
        params: { url: info.url, title: info.name ? info.name : item.vod_name, header: info.header ? info.header : '' }
      });
    } catch (e) { this.status = '详情加载失败'; }
  }

 build() {
    Column() {
      Text('影视仓鸿蒙版（阶段 2/3）').fontSize(20).fontWeight(FontWeight.Bold)
      Row() {
        TextInput({ placeholder: '搜索', text: this.keyword })
          .onChange((v: string) => { this.keyword = v; }).layoutWeight(1)
        Button('搜索').onClick(() => this.search()).margin({ left: 8 })
      }.width('100%').margin({ top: 12 })

      Scroll() {
        Row() {
          ForEach(this.sites, (s: SiteBean, i: number) => {
            Button(s.name).onClick(() => { this.selected = i; this.loadHome(); })
              .margin({ right: 8 })
              .backgroundColor(i === this.selected ? '#3179F5' : '#DDDDDD')
          })
        }
      }.width('100%').height(44).margin({ top: 8 })

      Text(this.status).fontSize(13).fontColor(Color.Gray).margin({ top: 8 })

      List() {
        ForEach(this.videos, (v: VodItem) => {
          ListItem() {
            Row() {
              Text(v.vod_name).fontSize(16).layoutWeight(1)
              Text(v.vod_remarks ? v.vod_remarks : '').fontSize(12).fontColor(Color.Gray)
            }.padding(12).onClick(() => this.play(v))
          }
        })
      }.layoutWeight(1).width('100%')

      // 隐藏的 ArkWeb：承载 JS Spider 运行时
      Web({ src: $rawfile('spider/runner.html'), controller: this.runnerController })
        .onControllerAttached(() => SpiderRuntime.getInstance().onControllerAttached())
        .onPageEnd(() => SpiderRuntime.getInstance().onPageEnd())
        .width(1).height(1).opacity(0)
    }
    .width('100%').height('100%').padding(12)
  }
}
