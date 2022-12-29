import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:hawaiian_game_slot/slot_game.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bar/slot_bar_bottom_reply_box.dart';

class SlotBonusGameItem extends SpriteAnimationComponent with Tappable, CollisionCallbacks, HasGameRef<SlotGame> {
  /// 是否停留
  bool _isStay = false;

  /// 是否移動
  bool _isMove = true;

  /// 預設速度
  final _defaultSpeed = 0.25;

  /// 測試模式
  final _isDebug = false;

  /// 碰撞檢測
  late ShapeHitbox _hitbox;

  /// 泡泡粒子特效精靈
  Sprite? _particleBubble;

  /// 最大泡泡粒子新增間隔
  int maxBubbleAddedStep = 100;

  /// 泡泡粒子新增間隔
  int bubbleAddedStep = 0;

  /// 老虎機Bonus遊戲模式物件
  SlotBonusGameItem({
    required SpriteAnimation animation,
    required Vector2? position,
    required Vector2? size,
  }) : super(animation: animation, position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = _isDebug);

    // 設置碰撞檢測
    _setupHitBox();

    // 設定泡泡粒子特效精靈
    // _setupParticleBubble();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isMove) {
      // 持續向下
      var x = position.x;
      var y = position.y + (dt * size.y * _defaultSpeed);
      position = Vector2(x, y);
    }

    // // 控制間隔新增泡泡粒子特效
    // if (bubbleAddedStep < maxBubbleAddedStep) {
    //   bubbleAddedStep++;
    // } else {
    //   // 新增泡泡粒子特效
    //   // addCircleParticle();
    //   // addBubbleParticle(position: Vector2(size.x / 2, size.y / 2));
    //   bubbleAddedStep = 0;
    // }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    // 與老虎機滾輪下方反應箱碰撞結束後將自己移除
    if (other is SlotBarBottomReplyBox) {
      gameRef.slotMachine.isReadyBonusGame = false;
      gameRef.slotMachine.bonusGameRecharge = 0;
      removeFromParent();
    }
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (_isMove) {
      _isMove = false;
    } else {
      _isMove = true;
    }
    // // 新增泡泡粒子特效
    // addBubbleParticle(position: info.eventPosition.viewport);
    return true;
  }

  /// 設置碰撞檢測
  void _setupHitBox() {
    _hitbox = RectangleHitbox();
    add(_hitbox);
  }

  // /// 設定泡泡粒子特效精靈
  // Future<void> _setupParticleBubble() async {
  //   _particleBubble = await Sprite.load('game/particle_bubble.png');
  // }

  // /// 新增泡泡粒子特效
  // void addBubbleParticle({required Vector2 position}) async {
  //   print("SlotBonusGameItem >> addBubbleParticle 新增泡泡粒子特效~~~");
  //   if (_particleBubble != null) {
  //     final rnd = Random();
  //     Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 100;
  //     Sprite bubbleSprite = await Sprite.load('game/particle_bubble.png');
  //     Particle particle = Particle.generate(
  //       count: 10,
  //       lifespan: 1,
  //       generator: (i) {
  //         return AcceleratedParticle(
  //           child: SpriteParticle(sprite: bubbleSprite, size: Vector2(26.0, 26.0)),
  //           acceleration: randomVector2(),
  //           speed: Vector2.zero(),
  //           position: position,
  //         );
  //       },
  //     );
  //
  //     final ParticleSystemComponent psc = ParticleSystemComponent(particle: particle);
  //     add(psc);
  //   }
  // }
  //
  // Vector2 randomVector() {
  //   Vector2 base = Vector2.random(Random());
  //   Vector2 fix = Vector2(-0.5, -0.5);
  //   base = base + fix; //  (-0.5, -0.5) ~ (0.5, 0.5)
  //   return base * 200;
  // }
  //
  // void addCircleParticle() {
  //   Random rnd = Random();
  //   Function randomOffset = () => Offset(
  //         rnd.nextDouble() * 200 - 100,
  //         rnd.nextDouble() * 200 - 100,
  //       );
  //
  //   game.add(ParticleSystemComponent(
  //       particle: Particle.generate(
  //           count: 10,
  //           generator: (i) => AcceleratedParticle(
  //               acceleration: randomOffset(),
  //               child: CircleParticle(
  //                 paint: Paint()..color = Colors.red,
  //               )))));
  // }
}
