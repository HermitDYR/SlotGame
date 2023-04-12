import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:hawaiian_game_slot/slot_game.dart';

class SlotGameSpinButton extends SpriteComponent with Tappable, HasGameRef<SlotGame> {
  /// 點擊
  Function(bool)? onTap;

  /// 是否滾動
  bool _isSpin = false;
  bool get isSpin => _isSpin;

  /// 是否鎖定
  bool _isLock = true;
  bool get isLock => _isLock;

  /// 預設速度
  final _defaultSpeed = 10;

  /// Sprite一般狀態
  Sprite spriteNormal;

  /// Sprite禁用狀態
  Sprite spriteDisabled;

  /// 老虎機滾動按鈕
  SlotGameSpinButton({
    required Vector2? position,
    required Vector2? size,
    required this.spriteNormal,
    required this.spriteDisabled,
    this.onTap,
  }) : super(position: position, size: size, sprite: spriteNormal, anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    sprite = isLock ? spriteDisabled : spriteNormal;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!(gameRef.slotMachine.gameRound == gameRef.gameMaxRound)) {
      // 滾動狀態時旋轉按鈕
      if (isSpin) {
        angle += _defaultSpeed * dt;
        angle %= 2 * math.pi;
      }
    }
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isLock) return true;
    // print("SlotGameSpinButton >> onTapUp~~~~~ isLock: $isLock, gameRef.slotMachine.gameRound: ${gameRef.slotMachine.gameRound}");

    // 更新滾動狀態
    setIsSpin(!isSpin);

    // 點擊回彈
    effectClickBounce();

    // 對外通知
    if (onTap != null) {
      onTap!(isSpin);
    }

    // 按鈕鎖定
    setIsLock(true);
    // Future.delayed(const Duration(milliseconds: 3000), () {
    //   // print("SlotGameSpinButton >> 解除鎖定!!!");
    //   // 按鈕解除鎖定
    //   setIsLock(false);
    // });

    return true;
  }

  /// 是否鎖定
  void setIsLock(bool lock) {
    _isLock = lock;
    sprite = isLock ? spriteDisabled : spriteNormal;
  }

  /// 是否滾動
  void setIsSpin(bool spin) {
    _isSpin = spin;
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
