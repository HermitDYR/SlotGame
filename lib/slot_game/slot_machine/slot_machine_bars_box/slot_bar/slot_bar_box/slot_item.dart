import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class SlotItem extends SpriteComponent {
  /// 索引
  int index;

  /// 內容編號
  int id = -1;

  /// 是否為目標物件
  bool isTarget;

  /// 是否為中獎物件
  bool isLottery;

  /// 測試模式
  final _isDebug = false;

  /// 預設速度
  final _defaultSpeed = 0.50;

  /// 老虎機滾輪物件
  SlotItem({
    required this.index,
    required this.id,
    required Sprite? sprite,
    required Vector2 size,
    required Vector2 position,
    this.isTarget = false,
    this.isLottery = false,
  }) : super(sprite: sprite, size: size, position: position, anchor: Anchor.center);

  // @override
  // void render(Canvas canvas) {
  //   if (_isDebug) {
  //     canvas.drawRect(size.toRect(), BasicPalette.white.paint());
  //     canvas.drawRect(const Rect.fromLTWH(0, 0, 3, 3), BasicPalette.red.paint());
  //     canvas.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), BasicPalette.blue.paint());
  //   }
  // }

  @override
  Future<void>? onLoad() {
    // TODO: implement onLoad
    if (_isDebug) {
      // TODO: 測試模式 (這個會降低效能，非必要不要開著)
      add(RectangleHitbox()..debugMode = _isDebug);
    }

    // repeatedEffectController();
    // noiseEffectController();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // if (isTarget) {
    //   angle += _defaultSpeed * dt;
    //   angle %= 2 * math.pi;
    // }
    //
    // if (isLottery) {
    //   scale = Vector2(1.5, 1.5);
    // }
  }

  // TODO: Effect
  /*
  * 【Flutter&Flame游戏 - 拾柒】构件特效 | 了解 Effect 体系 https://juejin.cn/post/7108170125479510030
  * 【Flutter&Flame游戏 - 拾捌】构件特效 | ComponentEffect 一族 https://juejin.cn/post/7108534574459650084
  * 【Flutter&Flame游戏 - 拾玖】构件特效 | 了解 EffectController 体系 https://juejin.cn/post/7108927950044528670
  * 【Flutter&Flame游戏 - 贰拾】构件特效 | 其他 EffectControler https://juejin.cn/post/7109251245784711182
  * */

  /// 靜止後的回彈
  void effectBounce() {
    EffectController noiseEffectController = NoiseEffectController(frequency: 1, duration: 0.5);
    Effect effect = MoveByEffect(Vector2(0, size.y / 4), noiseEffectController, onComplete: () {
      // print("effectBounce Finish!!!");
    });
    add(effect);
  }

  /// 靜止後回彈 >> 縮放
  void effectBounceAfterScale() {
    EffectController noiseEffectController = NoiseEffectController(frequency: 1, duration: 0.5);
    Effect effect1 = MoveByEffect(Vector2(0, size.y / 4), noiseEffectController, onComplete: () {
      EffectController child = SineEffectController(period: 0.5);
      int repeatCount = 2;
      EffectController repeatedEffectController = RepeatedEffectController(child, repeatCount);
      Effect effect2 = ScaleEffect.by(
        Vector2.all(1.2),
        repeatedEffectController,
        onComplete: () {
          // print("effectBounceAfterScale Finish!!!");
        },
      );
      add(effect2);
    });
    add(effect1);
  }

  void repeatedEffectController() {
    if (isLottery) {
      EffectController sineEffectController = SineEffectController(period: 0.1);
      int repeatCount = 5;
      EffectController repeatedEffectController = RepeatedEffectController(sineEffectController, repeatCount);
      Effect effect = MoveByEffect(
        Vector2(-10, 0),
        repeatedEffectController,
      );
      add(effect);
    }
  }
}
