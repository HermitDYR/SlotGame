import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:hawaiian_game_slot/slot_game.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bar.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine/slot_machine_bars_box/slot_bonus_game_item.dart';

class SlotMachineBarsBox extends PositionComponent with HasGameRef<SlotGame> {
  // TODO: PositionComponent
// class SlotMachineBarsBox extends ClipComponent with HasGameRef<SlotGame> {
  // TODO: ClipComponent

  /// 滾輪寬度
  double barWidth;

  /// 滾輪數量
  int barCount;

  /// 滾輪內的滾輪物件數量
  int barItemCount;

  /// 老虎機Bonus物件
  SlotBonusGameItem? slotBonusGameItem;

  /// 所有的滾輪皆進入停留狀態
  Function()? onAllBarStay;

  /// 測試模式
  final _isDebug = false;

  /// 停留次數
  int _barStayCount = 0;

  /// 老虎機滾輪組箱
  SlotMachineBarsBox({
    required this.barWidth,
    required this.barCount,
    required this.barItemCount,
    required Vector2? position,
    required Vector2? size,
    this.onAllBarStay,
  }) : super(position: position, size: size, anchor: Anchor.center); // TODO: PositionComponent
  // }) : super(builder: (size) => Rectangle.fromRect(size.toRect()), position: position, size: size, anchor: Anchor.center); // TODO: ClipComponent

  @override
  Future<void>? onLoad() {
    // TODO: PositionComponent
    // Future<void> onLoad() {
    // TODO: ClipComponent
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = _isDebug);

    // 設置老虎機滾輪
    _setupSlotBars();

    return super.onLoad();
  }

  /// 設置老虎機滾輪
  void _setupSlotBars() {
    final Vector2 position = Vector2(0, 0);
    final Vector2 size = Vector2(barWidth, barWidth * barItemCount);
    for (int i = 0; i < barCount; i++) {
      final slotBar = SlotBar(
        index: i,
        itemCount: barItemCount,
        position: Vector2(position.x + (i * size.x), position.y),
        size: size,
        onStayFromSlotBarBox: _onStayFromSlotBarBox,
      );
      add(slotBar);
    }
  }

  /// 取得老虎機滾輪
  SlotBar? getSlotBar({required int index}) {
    for (Component component in children.toList()) {
      if (component is SlotBar) {
        SlotBar slotBar = component;
        if (slotBar.index == index) {
          return component;
        }
      }
    }
    return null;
  }

  /// 老虎機滾輪物件箱進入停留狀態
  void _onStayFromSlotBarBox(int index) {
    print("SlotMachineBarsBox >> _onStayFromSlotBarBox index: $index");
    _barStayCount++;
    if (_barStayCount >= barCount) {
      if (onAllBarStay != null) {
        onAllBarStay!();
      }
      _barStayCount = 0;
    }
  }

  /// 新增老虎機Bonus遊戲模式物件
  Future<void> addBonusGameItem() async {
    // print("SlotMachineBarsBox >> addBonusGameItem~~~ 新增老虎機Bonus遊戲模式物件");
    const stepTime = 0.30;
    final textureSize = Vector2(377, 292);
    const frameCount = 9;
    final bonusGirl = await gameRef.loadSpriteAnimation(
      'game/bonus_girl_spritesheet.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final slotBonusGameItemSize = Vector2(size.x / 1.3, textureSize.y * (size.y / textureSize.x / 1.3));
    slotBonusGameItem = SlotBonusGameItem(
      animation: bonusGirl,
      position: Vector2(size.x / 2, (slotBonusGameItemSize.y / 2) * -1),
      size: slotBonusGameItemSize,
    );
    add(slotBonusGameItem!);
    return;
  }
}
