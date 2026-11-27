import { router } from '@kit.ArkUI';
import { XComponentController } from '@kit.ArkUI';
import { PlayerEngine } from '../player/PlayerEngine';

@Entry
@Component
struct Player {
  @State title: string = '播放';
  @State status: string = '';
  @State current: number = 0;
  @State duration: number = 0;
  @State speed: number = 1;
  @State showControls: boolean = true;
  private xcController: XComponentController = new XComponentController();
  private engine: PlayerEngine = new PlayerEngine();
  private url: string = '';
  private header: string = '';

  aboutToAppear(): void {
    const p = router.getParams() as Record<string, Object>;
    if (p) {
      this.url = p.url ? p.url as string : '';
      this.title = p.title ? p.title as string : '播放';
      this.header = p.header ? p.header as string : '';
    }
    this.engine.onTimeUpdate = (cur: number, dur: number) => {
      this.current = cur;
      this.duration = dur;
    };
    this.engine.onError = (msg: string) => { this.status = '播放错误：' + msg; };
  }

 aboutToDisappear(): void { this.engine.release(); }

 private async start(surfaceId: string): Promise<void> {
    let headers: Record<string, string> = {};
    if (this.header.length > 0) {
      try { headers = JSON.parse(this.header) as Record<string, string>; } catch (e) {}
    }
    try {
      await this.engine.prepare(this.url, headers, surfaceId);
      this.engine.play();
      this.status = '播放中';
    } catch (e) {
      this.status = '起播失败：' + (e as Error).message;
    }
  }

 build() {
    Stack() {
      XComponent({ id: 'playerSurface', type: 'surface', controller: this.xcController })
        .onLoad(() => { this.start(this.xcController.getXComponentSurfaceId()); })
        .width('100%').height('100%')
        .onClick(() => { this.showControls = !this.showControls; })

      if (this.showControls) {
        Column() {
          Text(this.title).fontSize(18).fontColor(Color.White)
          Text(this.status).fontSize(12).fontColor(Color.White)
          Slider({ value: this.current, min: 0, max: this.duration > 0 ? this.duration : 1 })
            .onChange((v: number) => { this.engine.seek(Math.round(v)); })
            .width('90%')
          Row() {
            Button('播放').onClick(() => this.engine.play())
            Button('暂停').onClick(() => this.engine.pause())
            Button('倍速').onClick(() => {
              this.speed = this.speed === 1 ? 1.5 : (this.speed === 1.5 ? 2 : 1);
              this.engine.setSpeed(this.speed);
            })
            Button('返回').onClick(() => router.back())
          }.margin({ top: 12 })
        }.width('100%').padding(16).backgroundColor('#99000000')
        .justifyContent(FlexAlign.End)
      }
    }.width('100%').height('100%')
  }
}
