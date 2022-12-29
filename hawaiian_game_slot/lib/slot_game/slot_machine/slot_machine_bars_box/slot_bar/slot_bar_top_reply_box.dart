import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bar/slot_bar_box.dart';

class SlotBarTopReplyBox extends PositionComponent with CollisionCallbacks {
  /// 索引
  int index;

  /// 測試模式
  final _isDebug = false;

  /// 碰撞檢測
  late ShapeHitbox _hitbox;

  /// 測試上色
  final Paint _paint = Paint()..color = Colors.grey.withAlpha(200);

  /// 老虎機滾輪上方反應箱
  SlotBarTopReplyBox({
    required this.index,
    required Vector2? position,
    required Vector2? size,
    // this.collisionIn,
    // this.collisionOut,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    if (_isDebug) {
      canvas.drawRect(size.toRect(), _paint);
    }
  }

  @override
  Future<void>? onLoad() async {
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = _isDebug);

    // 設置碰撞檢測
    _setupHitBox();

    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is SlotBarBox) {
      // print("onCollisionStart~~~~~ index: $index");
      _paint.color = Colors.green.withAlpha(200);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is SlotBarBox) {
      // print("onCollisionEnd~~~~~ index: $index");
      _paint.color = Colors.grey.withAlpha(200);
    }
  }

  /// 設置碰撞檢測
  void _setupHitBox() {
    _hitbox = RectangleHitbox();
    add(_hitbox);
  }
}
