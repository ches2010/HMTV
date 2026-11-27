import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { SiteConfig } from '../model/SiteConfig';

const STORE_NAME: string = 'tvbox_config';
const KEY_CONFIG_URL: string = 'configUrl';
const KEY_RAW_JSON: string = 'configJson';

export class ConfigStore {
  private static instance: ConfigStore = new ConfigStore();
  private pref: preferences.Preferences | undefined = undefined;

  static getInstance(): ConfigStore {
    return ConfigStore.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.pref === undefined) {
      this.pref = await preferences.getPreferences(context, STORE_NAME);
    }
  }

  async getConfigUrl(): Promise<string> {
    return this.pref ? (await this.pref.get(KEY_CONFIG_URL, '') as string) : '';
  }

  async setConfigUrl(url: string): Promise<void> {
    if (this.pref) {
      await this.pref.put(KEY_CONFIG_URL, url);
      await this.pref.flush();
    }
  }

  async saveRawConfig(json: string): Promise<void> {
    if (this.pref) {
      await this.pref.put(KEY_RAW_JSON, json);
      await this.pref.flush();
    }
  }

  async getRawConfig(): Promise<string> {
    return this.pref ? (await this.pref.get(KEY_RAW_JSON, '') as string) : '';
  }

  parseConfig(json: string): SiteConfig {
    const obj = JSON.parse(json) as SiteConfig;
    return obj;
  }
}
