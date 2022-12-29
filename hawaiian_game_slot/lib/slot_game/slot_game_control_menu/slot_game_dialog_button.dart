import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

class SlotGameDialogButton extends SpriteComponent with Tappable {
  /// 點擊
  Function()? onTap;

  /// 遊戲彈窗按鈕
  SlotGameDialogButton({
    required Sprite sprite,
    required Vector2? position,
    required Vector2? size,
    this.onTap,
  }) : super(position: position, size: size, sprite: sprite, anchor: Anchor.center);

  @override
  bool onTapUp(TapUpInfo info) {
    // 點擊回彈
    effectClickBounce();

    // 對外通知
    if (onTap != null) {
      onTap!();
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
