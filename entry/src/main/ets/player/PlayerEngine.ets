import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// AVPlayer 封装：支持 URL 与带 Header 的 MediaSource（API 12+）。
export class PlayerEngine {
  private player?: media.AVPlayer;
 private surfaceId: string = '';
  onTimeUpdate?: (current: number, duration: number) => void;
  onStateChange?: (state: string) => void;
 onError?: (message: string) => void;

 async prepare(url: string, headers: Record<string, string>, surfaceId: string): Promise<void> {
    this.surfaceId = surfaceId;
    const p: media.AVPlayer = await media.createAVPlayer();
    this.player = p;
    p.on('stateChange', (state: string) => {
      hilog.info(0x0000, 'TVBoxPort', 'player state: %{public}s', state);
      if (this.onStateChange) this.onStateChange(state);
    });
    p.on('timeUpdate', (time: number) => {
      if (this.onTimeUpdate) this.onTimeUpdate(time, p.duration);
    });
    p.on('error', (err: BusinessError) => {
      if (this.onError) this.onError(err.code + ' ' + err.message);
    });
    if (surfaceId.length > 0) {
      // surfaceId 必须在 initialized 状态（prepare 之前）设置
      p.surfaceId = surfaceId;
    }
    if (Object.keys(headers).length > 0) {
      const source: media.MediaSource = media.createMediaSourceWithUrl(url, headers);
      p.setMediaSource(source);
    } else {
      p.url = url;
    }
    await p.prepare();
 }

 play(): void { this.player?.play(); }
 pause(): void { this.player?.pause(); }
 seek(ms: number): void { this.player?.seek(ms); }
 setSpeed(speed: number): void { this.player?.setSpeed(speed); }
 get duration(): number { return this.player ? this.player.duration : 0; }
 release(): void {
    if (this.player) {
      this.player.stop();
      this.player.release();
      this.player = undefined;
    }
  }
}
