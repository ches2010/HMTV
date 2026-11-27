import { webview } from '@kit.ArkWeb';
import { JsBridge } from './JsBridge';

// 承载 JS Spider 的 ArkWeb 运行时单例。Web 组件需挂载在页面中（宽高 1px 即可）。
export class SpiderRuntime {
  private static instance_: SpiderRuntime = new SpiderRuntime();
 readonly controller: webview.WebviewController = webview.createWebviewController();
  readonly bridge: JsBridge = new JsBridge();
 private pageReady_: boolean = false;
 private registered_: boolean = false;

  static getInstance(): SpiderRuntime {
    return SpiderRuntime.instance_;
  }

 onControllerAttached(): void {
    if (!this.registered_) {
      // asyncMethodList 中的 fetch 返回 Promise，JS 侧用 await 调用。
      this.controller.registerJavaScriptProxy(this.bridge, 'TVBoxBridge',
        ['fetch', 'log', 'getExt'], ['fetch']);
      this.registered_ = true;
    }
  }

 onPageEnd(): void {
    this.pageReady_ = true;
  }

 isReady(): boolean {
    return this.pageReady_;
  }

 async waitReady(): Promise<void> {
    for (let i = 0; i < 50 && !this.pageReady_; i++) {
      await new Promise<void>((resolve) => setTimeout(resolve, 100));
    }
    if (!this.pageReady_) throw new Error('Spider Web runtime not ready');
  }

 private run(script: string): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      this.controller.runJavaScript(script, (err: Error, value: string) => {
        if (err) reject(err);
        else resolve(value);
      });
    });
  }

 async installScript(script: string, ext: string): Promise<void> {
    await this.waitReady();
    this.bridge.setExt(ext);
    const wrapped = 'window.__installSpider(' + JSON.stringify(script) + ',' + JSON.stringify(ext) + ')';
    await this.run(wrapped);
  }

 async call(method: string, args: Object[]): Promise<string> {
    await this.waitReady();
    const params: string = args.map((v: Object) => JSON.stringify(v)).join(',');
    const script = '(async()=>{return JSON.stringify(await window.__callSpider(' + JSON.stringify(method) + ',[' + params + ']));})()';
    const raw = await this.run(script);
    if (!raw) return '{}';
    try {
      return JSON.parse(raw) as string;
    } catch (e) {
      return raw;
    }
  }
}
