import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 注入到 ArkWeb 的 JSAPI；只暴露必要方法，禁止 file:// 与本地文件访问。
export class JsBridge {
  private ext_: string = '';

  setExt(ext: string): void {
    this.ext_ = ext;
  }

 getExt(): string {
    return this.ext_;
  }

 log(msg: string): void {
    hilog.info(0x0000, 'TVBoxPort', 'JS: %{public}s', msg);
  }

 async fetch(url: string, optionsJson: string): Promise<string> {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return JSON.stringify({ ok: false, status: 0, body: 'unsupported scheme' });
      }
      let method: http.RequestMethod = http.RequestMethod.GET;
      let header: Record<string, string> = {};
      let body: string = '';
      if (optionsJson && optionsJson.length > 0) {
        const opt = JSON.parse(optionsJson) as Record<string, Object>;
        if (opt.method) method = opt.method as http.RequestMethod;
        if (opt.headers) header = opt.headers as Record<string, string>;
        if (opt.body) body = opt.body as string;
      }
      const req = http.createHttp();
      const res = await req.request(url, {
        method: method,
        header: header,
        extraData: body,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      const out = JSON.stringify({ ok: true, status: res.responseCode, body: res.result as string });
      req.destroy();
      return out;
    } catch (e) {
      const err = e as Error;
      return JSON.stringify({ ok: false, status: 0, body: err.message });
    }
  }
}
