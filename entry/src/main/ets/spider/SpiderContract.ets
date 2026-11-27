// 对齐源项目 Spider.java 的接口契约（阶段 2 实现）。
export interface SpiderContract {
  init(ext: string): void;
 homeContent(filter: boolean): Promise<string>;
 homeVideoContent(): Promise<string>;
 categoryContent(tid: string, pg: string, filter: boolean, extend: Map<string, string>): Promise<string>;
 detailContent(ids: string[]): Promise<string>;
 searchContent(key: string, quick: boolean, pg?: string): Promise<string>;
 playerContent(flag: string, id: string, vipFlags: string[]): Promise<string>;
 liveContent(url: string): Promise<string>;
 isVideoFormat(url: string): boolean;
 manualVideoCheck(): boolean;
 cancelByTag(): void;
 destroy(): void;
 proxy(params: Map<string, string>): Object[] | undefined;
 action(action: string): string | undefined;
}
