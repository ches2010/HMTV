import { http } from '@kit.NetworkKit';

export interface RewriteResult {
  url: string;
  headers: Record<string, string>;
}

// 复刻 TVBox 配置中的 hosts / doh 能力，解决域名无法解析的问题。
class NetworkPolicy {
  private static instance_: NetworkPolicy = new NetworkPolicy();
  private hosts_: Map<string, string> = new Map<string, string>();
  private doh_: string[] = [];

 static getInstance(): NetworkPolicy { return NetworkPolicy.instance_; }

 configure(rawJson: string): void {
    this.hosts_.clear();
    this.doh_ = [];
    try {
      const obj = JSON.parse(rawJson) as Record<string, Object>;
      const hosts = obj['hosts'] as string[] | undefined;
      if (hosts) {
        for (const item of hosts) {
          const idx = item.indexOf('=');
          if (idx > 0) {
            const from = item.substring(0, idx).trim().toLowerCase();
            const to = item.substring(idx + 1).trim();
            this.hosts_.set(from, to);
          }
        }
      }
      const doh = obj['doh'] as Object[] | undefined;
      if (doh) {
        for (const d of doh) {
          const rec = d as Record<string, Object>;
          const u = rec['url'] as string | undefined;
          if (u && u.length > 0) this.doh_.push(u);
        }
      }
    } catch (e) {}
  }

 private splitAuthority(authority: string): string[] {
    if (authority.startsWith('[')) {
      const end = authority.indexOf(']');
      if (end > 0) return [authority.substring(0, end + 1), authority.substring(end + 1)];
    }
    const colon = authority.lastIndexOf(':');
    if (colon > 0) return [authority.substring(0, colon), authority.substring(colon)];
    return [authority, ''];
  }

 async rewrite(raw: string): Promise<RewriteResult> {
    const marker = '://';
    const i = raw.indexOf(marker);
    if (i < 0) return { url: raw, headers: {} };
    const scheme = raw.substring(0, i + 3);
    const rest = raw.substring(i + 3);
    const slash = rest.indexOf('/');
    const authority = slash >= 0 ? rest.substring(0, slash) : rest;
    const path = slash >= 0 ? rest.substring(slash) : '';
    const parts = this.splitAuthority(authority);
    const host = parts[0];
    const port = parts[1];
    const mapped = this.hosts_.get(host.toLowerCase());
    let newHost = host;
    let headers: Record<string, string> = {};
    if (mapped && mapped.length > 0 && mapped !== 'ip') {
      newHost = mapped;
    } else if (mapped === 'ip' || (!mapped && this.doh_.length > 0)) {
      const ip = await this.resolveByDoh(host);
      if (ip.length > 0) {
        newHost = ip;
        headers['Host'] = host;
      }
    }
    return { url: scheme + newHost + port + path, headers: headers };
  }

 private async resolveByDoh(host: string): Promise<string> {
    for (const endpoint of this.doh_) {
      try {
        const mapped = this.hosts_.get(endpoint.toLowerCase());
        let target = endpoint;
        if (mapped && mapped.length > 0 && mapped !== 'ip') target = mapped;
        const sep = target.includes('?') ? '&' : '?';
        const url = target + sep + 'name=' + encodeURIComponent(host) + '&type=A';
        let header: Record<string, string> = { 'accept': 'application/dns-json' };
        const req = http.createHttp();
        const res = await req.request(url, {
          method: http.RequestMethod.GET,
          header: header,
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 8000,
          readTimeout: 8000
        });
        req.destroy();
        const body = res.result as string;
        const obj = JSON.parse(body) as Record<string, Object>;
        const answers = obj['Answer'] as Object[] | undefined;
        if (answers) {
          for (const a of answers) {
            const rec = a as Record<string, Object>;
            const type = rec['type'] as number;
            const data = rec['data'] as string | undefined;
            if (type === 1 && data && data.length > 0) return data;
          }
        }
      } catch (e) {}
    }
    return '';
  }
}

export let networkPolicy = NetworkPolicy.getInstance();
