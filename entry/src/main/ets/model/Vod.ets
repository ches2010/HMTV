// TVBox VOD JSON 数据模型（对齐 Spider.java 返回的字符串结构）。
export interface VodItem {
  vod_id: string;
  vod_name: string;
 vod_pic?: string;
  vod_remarks?: string;
  vod_play_from?: string;
 vod_play_url?: string;
 vod_content?: string;
}

export interface VodClass {
  type_id: string;
 type_name: string;
}

export interface VodList {
  list: VodItem[];
  class?: VodClass[];
 page?: number;
 pagecount?: number;
}

export interface PlayInfo {
  url: string;
 header?: string;
  parse?: string;
  name?: string;
}
