import { http } from '@kit.NetworkKit';
import { SpiderContract } from './SpiderContract';
import { networkPolicy } from '../config/NetworkPolicy';

// 对应 TVBox 配置 type=1(json)/0(xml)/4(remote) 的通用 HTTP JSON 采集接口。
export class HttpSpider implements SpiderContract {
  private api_: string;
  private ext_: string = '';
 constructor(api: string) { this.api_ = api; }
  init(ext: string): void { this.ext_ = ext; }

 private async get(extra: string): Promise<string> {
    const sep = this.api_.includes('?') ? '&' : '?';
    const rewritten = await networkPolicy.rewrite(this.api_ + sep + extra);
    const req = http.createHttp();
    try {
      const res = await req.request(rewritten.url, {
        method: http.RequestMethod.GET,
        header: rewritten.headers,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      return res.result as string;
    } finally {
      req.destroy();
    }
  }

 homeContent(filter: boolean): Promise<string> { return this.get('ac=home'); }
  homeVideoContent(): Promise<string> { return this.get('ac=videolist&pg=1'); }
  categoryContent(tid: string, pg: string, filter: boolean, extend: Map<string, string>): Promise<string> {
    return this.get('ac=videolist&t=' + encodeURIComponent(tid) + '&pg=' + encodeURIComponent(pg));
  }
  detailContent(ids: string[]): Promise<string> { return this.get('ac=detail&ids=' + encodeURIComponent(ids.join(','))); }
  searchContent(key: string, quick: boolean, pg?: string): Promise<string> {
    return this.get('wd=' + encodeURIComponent(key) + '&pg=' + encodeURIComponent(pg ? pg : '1'));
  }
  async playerContent(flag: string, id: string, vipFlags: string[]): Promise<string> {
    return JSON.stringify({ url: id, header: '', parse: '' });
  }
  liveContent(url: string): Promise<string> { return this.get('ac=live'); }
  isVideoFormat(url: string): boolean { return url.endsWith('.m3u8') || url.endsWith('.mp4'); }
  manualVideoCheck(): boolean { return false; }
  cancelByTag(): void {}
  destroy(): void {}
  proxy(params: Map<string, string>): Object[] | undefined { return undefined; }
  action(action: string): string | undefined { return undefined; }
}
