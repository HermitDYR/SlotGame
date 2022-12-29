import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

class SlotGameBgmButton extends SpriteComponent with Tappable {
  /// 是否開啟
  bool isOpen = true;

  /// 點擊
  Function(bool)? onTap;

  /// Sprite一般狀態
  Sprite spriteNormal;

  /// Sprite禁用狀態
  Sprite spriteDisabled;

  /// 老虎機背景音樂按鈕
  SlotGameBgmButton({
    required Vector2? position,
    required Vector2? size,
    required this.spriteNormal,
    required this.spriteDisabled,
    this.onTap,
  }) : super(position: position, size: size, sprite: spriteNormal, anchor: Anchor.center);

  @override
  bool onTapUp(TapUpInfo info) {
    // 更新開關
    isOpen = !isOpen;

    // 設置精靈
    sprite = (isOpen) ? spriteNormal : spriteDisabled;

    // 點擊回彈
    effectClickBounce();

    // 對外通知
    if (onTap != null) {
      onTap!(isOpen);
    }

    return true;
  }

  /// 點擊回彈
  void effectClickBounce() {
    EffectController sineEffectController = SineEffectController(period: 0.5);
    int repeatCount = 1;
    EffectController repeatedEffectController = RepeatedEffectController(sineEffectController, repeatCount);
    Effect effect = ScaleEffect.by(
      Vector2.all(0.8),
      repeatedEffectController,
      onComplete: () {
        // print("effectBounceAfterScale Finish!!!");
      },
    );
    add(effect);
  }
}
