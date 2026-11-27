import { SpiderContract } from './SpiderContract';
import { SpiderRuntime } from './SpiderRuntime';

// 通过 ArkWeb 执行站点 JS 的 Spider 实现。
export class JsSpider implements SpiderContract {
  private key_: string;
  private ext_: string = '';
  constructor(siteKey: string) { this.key_ = siteKey; }

 init(ext: string): void { this.ext_ = ext; }
  async install(script: string): Promise<void> {
    await SpiderRuntime.getInstance().installScript(script, this.ext_);
  }
  private invoke(method: string, args: Object[]): Promise<string> {
    return SpiderRuntime.getInstance().call(method, args);
  }
  homeContent(filter: boolean): Promise<string> { return this.invoke('homeContent', [filter]); }
  homeVideoContent(): Promise<string> { return this.invoke('homeVideoContent', []); }
  categoryContent(tid: string, pg: string, filter: boolean, extend: Map<string, string>): Promise<string> {
    const plain: Record<string, string> = {};
    extend.forEach((value: string, key: string) => { plain[key] = value; });
    return this.invoke('categoryContent', [tid, pg, filter, plain]);
  }
  detailContent(ids: string[]): Promise<string> { return this.invoke('detailContent', [ids]); }
  searchContent(key: string, quick: boolean, pg?: string): Promise<string> {
    return this.invoke('searchContent', [key, quick, pg ? pg : '1']);
  }
  playerContent(flag: string, id: string, vipFlags: string[]): Promise<string> {
    return this.invoke('playerContent', [flag, id, vipFlags]);
  }
  liveContent(url: string): Promise<string> { return this.invoke('liveContent', [url]); }
  isVideoFormat(url: string): boolean { return url.endsWith('.m3u8') || url.endsWith('.mp4'); }
  manualVideoCheck(): boolean { return false; }
  cancelByTag(): void {}
  destroy(): void {}
  proxy(params: Map<string, string>): Object[] | undefined { return undefined; }
  action(action: string): string | undefined { return undefined; }
  get siteKey(): string { return this.key_; }
}
