import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:hawaiian_game_slot/slot_game.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bar/slot_bar_bottom_reply_box.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bar/slot_bar_box/slot_item.dart';

class SlotBarBox extends PositionComponent with /*CollisionCallbacks,*/ HasGameRef<SlotGame> {
  /// 索引
  int index;

  /// 老虎機滾輪物件數量
  int itemCount;

  /// 老虎機滾輪物件內容編號陣列
  List<int>? itemIdList;

  /// 老虎機滾輪物件中獎索引陣列
  List<int>? itemLotteryIndexList;

  /// 生成位置
  Vector2? _generatePosition;

  /// 停留位置
  Vector2? stayPosition;

  /// 移除位置
  Vector2? removePosition;

  /// 是否進入移除位置
  Function(int index)? onRemovePosition;

  /// 是否停留
  bool isStay;

  /// 進入停留狀態
  Function(int index)? onStay;

  /// 是否移動
  bool isMove = true;

  /// 是否發生碰撞
  // bool isCollisionWithBottomReplyBox = false;

  /// 進入碰撞
  // Function(int index)? onCollisionWithBottomReplyBox;

  /// 測試模式
  final _isDebug = false;

  /// 碰撞檢測
  // late ShapeHitbox _hitbox;

  /// 預設速度
  ///
  /// TODO: 如果SlotBarBox向下更新速度過快，可能會導致與SlotBarBottomReplayBox的碰撞事件失效
  /// - 解法，當SlotBarBox向下更新速度越快，則SlotBarBottomReplayBox須往Y軸下方多偏移一些位置，讓碰撞監聽正常
  double speed = 2.5;
  //
  /// 錨點陣列
  List<Vector2>? _anchorPoints;

  /// 老虎機滾輪物件箱
  SlotBarBox({
    required this.index,
    required this.itemCount,
    required Vector2? position,
    required Vector2? size,
    required this.stayPosition,
    required this.removePosition,
    required this.speed,
    this.isStay = false,
    this.onStay,
    this.itemIdList,
    this.itemLotteryIndexList,
    this.onRemovePosition,
    // this.onCollisionWithBottomReplyBox,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    // add(RectangleHitbox()..debugMode = _isDebug);

    _generatePosition = position;

    // // 設置碰撞檢測
    // _setupHitBox();

    // 設定錨點陣列
    _setupAnchorPoints();

    // 設置老虎機滾輪物件組
    _setupSlotItems();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 如果停留狀態啟用，則停止在停留點
    if (isStay) {
      if (stayPosition != null && position.y > stayPosition!.y) {
        position = stayPosition!;
        // print("SlotBarBox $index >> update to isStay~~~");
        isMove = !isStay;

        // 展示彈跳效果
        showBounce();

        if (onStay != null) {
          // 進入停留狀態
          onStay!(index);
        }
      }
    }

    if (isMove) {
      // 持續向下
      var x = position.x;
      var y = position.y + (dt * size.y * speed);
      position = Vector2(x, y);
    }

    if (position.y >= removePosition!.y) {
      // 刪除
      removeFromParent();
      if (onRemovePosition != null) {
        onRemovePosition!(index);
      }
    }
  }

  // @override
  // void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   super.onCollisionStart(intersectionPoints, other);
  //   // 與老虎機滾輪下方反應箱碰撞開始後對外通知
  //   if (other is SlotBarBottomReplyBox) {
  //     // print("onCollisionStart~~~ SlotBarBottomReplyBox");
  //     // 透過isCollisionWithBottomReplyBox當旗標，過濾碰撞開始onCollisionStart()頻繁的通知
  //     if (!isCollisionWithBottomReplyBox) {
  //       isCollisionWithBottomReplyBox = true;
  //       // print("isCollisionWithBottomReplyBox: $isCollisionWithBottomReplyBox, isStay: $isStay");
  //       // 如果停留狀態不啟用
  //       if (!isStay) {
  //         // 對外通知進入碰撞
  //         if (onCollisionWithBottomReplyBox != null) {
  //           onCollisionWithBottomReplyBox!(index);
  //         }
  //       }
  //     }
  //   }
  // }

  // @override
  // void onCollisionEnd(PositionComponent other) {
  //   super.onCollisionEnd(other);
  //
  //   // 與老虎機滾輪下方反應箱碰撞結束後將自己移除
  //   if (other is SlotBarBottomReplyBox) {
  //     removeFromParent();
  //   }
  // }

  // /// 設置碰撞檢測
  // void _setupHitBox() {
  //   _hitbox = RectangleHitbox();
  //   add(_hitbox);
  // }

  /// 測試錨點標示物件
  RectangleComponent _getDebugAnchorItem({
    required Vector2 size,
    required Vector2 position,
    required Color pointColor,
    required Color contentColor,
  }) {
    return RectangleComponent(
        size: size,
        position: position,
        anchor: Anchor.center,
        children: [
          CircleComponent(
              radius: 15,
              position: Vector2(size.x / 2, size.y / 2),
              anchor: Anchor.center,
              paint: Paint()
                ..color = pointColor
                ..style = PaintingStyle.fill)
        ],
        paint: Paint()
          ..color = contentColor
          ..style = PaintingStyle.fill);
  }

  /// 設定錨點陣列
  void _setupAnchorPoints() {
    _anchorPoints ??= [];
    var itemWidth = size.x;
    var itemHeight = size.y / itemCount;
    var startPoint = Vector2(itemWidth / 2, itemHeight / 2);
    for (int i = 0; i < itemCount; i++) {
      var point = Vector2(startPoint.x, startPoint.y + (i * itemHeight));
      _anchorPoints!.add(point);
      if (_isDebug) {
        add(_getDebugAnchorItem(
          size: Vector2(itemWidth, itemWidth),
          position: point,
          pointColor: (itemIdList != null) ? Colors.white : Colors.black,
          contentColor: (itemIdList != null) ? Colors.white.withAlpha(150) : Colors.black.withAlpha(150),
        ));
      }
    }
  }

  /// 設置老虎機滾輪物件組
  void _setupSlotItems() {
    for (int i = 0; i < itemCount; i++) {
      // 判斷是否為中獎物件
      bool isLottery = false;
      if (itemLotteryIndexList != null) {
        final find = itemLotteryIndexList!.where((element) {
          return (element == i);
        });
        isLottery = (find.isNotEmpty);
      }

      // 裝載物件
      itemIdList ??= [];
      if (i < (itemIdList!.length)) {
        final itemId = itemIdList![i];
        final targetSlotItem = SlotItem(
          index: i,
          id: itemId,
          sprite: gameRef.slotMachine.rollItemSprites[itemId],
          size: Vector2(size.x * 1, size.x * 1),
          position: _anchorPoints![i],
          isTarget: true,
          isLottery: isLottery,
        );
        add(targetSlotItem);
      } else {
        final itemId = Random().nextInt(gameRef.slotMachine.rollItemSpritesCount);
        final randomSlotItem = SlotItem(
          index: i,
          id: itemId,
          sprite: gameRef.slotMachine.rollItemSprites[itemId],
          size: Vector2(size.x * 1, size.x * 1),
          position: _anchorPoints![i],
          isTarget: false,
          isLottery: isLottery,
        );
        add(randomSlotItem);
      }
    }
  }

  /// 取得老虎機滾輪
  SlotItem? getSlotItem({required int index}) {
    for (Component component in children.toList()) {
      if (component is SlotItem) {
        SlotItem slotItem = component;
        if (slotItem.index == index) {
          return component;
        }
      }
    }
    return null;
  }

  /// 展示彈跳效果
  void showBounce() {
    for (int i = 0; i < itemCount; i++) {
      SlotItem? slotItem = getSlotItem(index: i);
      if (slotItem != null) {
        // 靜止後的回彈
        slotItem.effectBounce();
      }
    }
  }

  /// 展示中獎效果
  void showLottery() {
    for (int i = 0; i < itemCount; i++) {
      SlotItem? slotItem = getSlotItem(index: i);
      if (slotItem != null) {
        if (slotItem.isLottery) {
          // 靜止後回彈 >> 縮放
          slotItem.effectBounceAfterScale();
        }
      }
    }
  }
}
