import { VodClass, VodItem, VodList, PlayInfo } from './Vod';

export class VodParser {
  static parseList(json: string): VodList {
    try {
      const obj = JSON.parse(json) as VodList;
      if (obj && obj.list) return obj;
    } catch (e) {}
    return { list: [] };
  }

 static parseClasses(json: string): VodClass[] {
    try {
      const obj = JSON.parse(json) as VodList;
      return obj.class ? obj.class : [];
    } catch (e) {}
    return [];
  }

 static firstPlay(json: string): PlayInfo | undefined {
    let item: VodItem | undefined;
    try {
      const detail = JSON.parse(json) as VodList;
      if (detail.list && detail.list.length > 0) item = detail.list[0];
    } catch (e) {}
    if (!item || !item.vod_play_url) return undefined;
    // TVBox 播放列表格式：来源$$$标题$地址#标题$地址
    const groups = item.vod_play_url.split('$$$');
    const firstGroup = groups.length > 0 ? groups[0] : '';
    const first = firstGroup.split('#')[0];
    const idx = first.indexOf('$');
    const url = idx >= 0 ? first.substring(idx + 1) : first;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return { url: url, name: item.vod_name, header: '' };
    }
    // 非直链交由 parses/嗅探，本骨架先返回原始串
    return { url: url, name: item.vod_name, parse: url };
  }
}
