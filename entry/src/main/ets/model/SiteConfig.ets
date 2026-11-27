// 与 TVBoxOS README 中的配置 JSON 对齐的最小数据模型。
export interface SiteBean {
  key: string;
  name: string;
  type: number;
  api: string;
 searchable?: number;
 filterable?: number;
 jar?: string;
 ext?: string;
}

export interface ParseBean {
  name: string;
 type: number;
 url: string;
}

export interface SiteConfig {
  spider?: string;
  wallpaper?: string;
  sites: SiteBean[];
  parses: ParseBean[];
  hosts?: string[];
  lives?: Object[];
 rules?: Object[];
  doh?: Object[];
}
