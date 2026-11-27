import { SiteBean } from '../model/SiteConfig';
import { SpiderContract } from './SpiderContract';
import { HttpSpider } from './HttpSpider';
import { JsSpider } from './JsSpider';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class SpiderFactory {
  static create(site: SiteBean): SpiderContract {
    // type: 0=xml 1=json 3=jar 4=remote（TVBox README）
    if (site.type === 3) {
      // JAR 无法在鸿蒙加载；期望 api 指向可执行的 JS 源。
      if (site.api.startsWith('http://') || site.api.startsWith('https://')) {
        return new JsSpider(site.key);
      }
      hilog.warn(0x0000, 'TVBoxPort', 'JAR spider is not supported on HarmonyOS: %{public}s', site.key);
    }
    return new HttpSpider(site.api);
  }
}
