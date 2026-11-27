import { SpiderContract } from './SpiderContract';

// 阶段 2 占位实现：计划用 ArkWeb 执行 cat.js + JavaScriptProxy 注入 JSAPI。
export class JsSpiderStub implements SpiderContract {
  private siteKey_: string;
  constructor(siteKey: string) {
    this.siteKey_ = siteKey;
  }
  init(ext: string): void {}
  async homeContent(filter: boolean): Promise<string> { return '{}'; }
  async homeVideoContent(): Promise<string> { return '{}'; }
  async categoryContent(tid: string, pg: string, filter: boolean, extend: Map<string, string>): Promise<string> { return '{}'; }
  async detailContent(ids: string[]): Promise<string> { return '{}'; }
  async searchContent(key: string, quick: boolean, pg?: string): Promise<string> { return '{}'; }
  async playerContent(flag: string, id: string, vipFlags: string[]): Promise<string> { return '{}'; }
  async liveContent(url: string): Promise<string> { return '{}'; }
  isVideoFormat(url: string): boolean { return false; }
  manualVideoCheck(): boolean { return false; }
  cancelByTag(): void {}
  destroy(): void {}
  proxy(params: Map<string, string>): Object[] | undefined { return undefined; }
  action(action: string): string | undefined { return undefined; }
  get siteKey(): string { return this.siteKey_; }
}
