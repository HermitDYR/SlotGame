import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hawaiian_game_slot/slot_game.dart';
import 'package:hawaiian_game_slot/slot_game/slot_game_control_menu/slot_game_bgm_button.dart';
import 'package:hawaiian_game_slot/slot_game/slot_game_control_menu/slot_game_link_tips_dialog.dart';
import 'package:hawaiian_game_slot/slot_game/slot_game_control_menu/slot_game_spin_button.dart';

class SlotGameControlMenu extends PositionComponent with HasGameRef<SlotGame> {
  /// 測試模式
  final _isDebug = false;

  /// 老虎機背景音樂按鈕
  SlotGameBgmButton? slotGameBgmButton;

  /// 老虎機滾動按鈕
  SlotGameSpinButton? slotGameSpinButton;

  /// 得分框
  TextComponent? winTextBox;

  /// 得分彈窗
  SpriteComponent? winDialog;

  /// 下注框
  TextComponent? betTextBox;

  /// 餘額框
  TextComponent? balanceTextBox;

  /// 老虎機遊戲外連提示彈窗
  SlotGameLinkTipsDialog? linkTipsDialog;

  /// 內間距
  final innerSpacing = 10.0;

  /// 下方控制欄位大小
  Vector2? bottomBarSize;

  /// 下方控制欄位
  RectangleComponent? bottomBar;

  /// 文字風格
  TextPaint textPaint = TextPaint(
    style: GoogleFonts.abel(
      fontSize: 30.0,
      color: Colors.white,
    ),
    // style: const TextStyle(
    //   fontSize: 30.0,
    //   fontFamily: 'Awesome Font',
    //   color: Colors.white,
    // ),
  );

  /// 老虎機遊戲控制選單
  SlotGameControlMenu({
    required Vector2? position,
    required Vector2? size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = _isDebug);

    // 下方控制欄位
    await _setupBottomBar();

    return super.onLoad();
  }

  /// 下方控制欄位
  Future<void> _setupBottomBar() async {
    bottomBarSize = Vector2(size.x, size.y * 0.1);
    bottomBar = RectangleComponent(
        size: bottomBarSize,
        position: Vector2(size.x / 2, size.y - bottomBarSize!.y / 2),
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.black.withAlpha(150)
          ..style = PaintingStyle.fill);
    add(bottomBar!);

    // 設置老虎機背景音樂按鈕
    await _setupSlotGameBgmButton(component: bottomBar!);

    // 老虎機滾動按鈕
    await _setupSlotGameSpinButton(component: bottomBar!);

    // 設置得分框
    await _setupWinTextBox(component: bottomBar!);

    // 設置下注框
    await _setupBetTextBox(component: bottomBar!);

    // 設置額度
    await _setupBalance(component: bottomBar!);
    return;
  }

  /// 設置老虎機背景音樂按鈕
  Future<void> _setupSlotGameBgmButton({required Component component}) async {
    final sprite = await Sprite.load('game/bgm_open.png');
    final spriteDisabled = await Sprite.load('game/bgm_close.png');
    Vector2 spritePosition = Vector2(bottomBarSize!.x - (bottomBarSize!.y * 0.5 / 2 + 10.0), bottomBarSize!.y / 2);
    Vector2 spriteSize = Vector2(bottomBarSize!.y * 0.5, bottomBarSize!.y * 0.5);
    slotGameBgmButton = SlotGameBgmButton(
      position: spritePosition,
      size: spriteSize,
      spriteNormal: sprite,
      spriteDisabled: spriteDisabled,
      onTap: _onTapBgmButton,
    );
    component.add(slotGameBgmButton!);
    return;
  }

  /// 老虎機背景音樂按鈕點擊事件
  _onTapBgmButton(bool isSpin) {
    // print("_onTapBgmButton");
    if (gameRef.bgmAudioPlayer != null) {
      if (gameRef.bgmAudioPlayer!.state == PlayerState.playing) {
        gameRef.bgmAudioPlayer!.pause();
      } else if (gameRef.bgmAudioPlayer!.state == PlayerState.paused) {
        gameRef.bgmAudioPlayer!.resume();
      }
    }
  }

  /// 設置老虎機滾動按鈕
  Future<void> _setupSlotGameSpinButton({required Component component}) async {
    final sprite = await Sprite.load('game/spin_button.png');
    final spriteDisabled = await Sprite.load('game/spin_button_disabled.png');
    Vector2 spritePosition = Vector2(bottomBarSize!.x / 2, bottomBarSize!.y / 2);
    Vector2 spriteSize = Vector2(bottomBarSize!.y * 0.8, bottomBarSize!.y * 0.8);
    slotGameSpinButton = SlotGameSpinButton(
      position: spritePosition,
      size: spriteSize,
      spriteNormal: sprite,
      spriteDisabled: spriteDisabled,
      onTap: _onTapSpinButton,
    );
    component.add(slotGameSpinButton!);

    Future.delayed(Duration(milliseconds: gameRef.slotMachine.slotBarDelayMilliseconds * 10), () {
      slotGameSpinButton!.setIsLock(false);
    });
    return;
  }

  /// 老虎機滾動按鈕點擊事件
  _onTapSpinButton(bool isSpin) {
    // print("_onTapSpinButton");
    if (gameRef.slotMachine.isSpin) {
      gameRef.slotMachine.stop();
    } else {
      gameRef.slotMachine.spin();
    }
  }

  /// 設置得分框
  Future<void> _setupWinTextBox({required Component component}) async {
    final positionComponent = PositionComponent(
      size: Vector2((bottomBarSize!.x - innerSpacing * 2) / 2, (bottomBarSize!.y - innerSpacing * 2) / 3),
      position: Vector2(innerSpacing, (bottomBarSize!.y - innerSpacing * 2) / 3 * 0 + innerSpacing),
    );
    final sprite = await Sprite.load('game/win_text.png');
    final spriteSize = Vector2(54.0, 26.0);
    final spriteComponent = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      position: Vector2(0, (positionComponent.size.y - spriteSize.y) / 2),
    );
    winTextBox = TextComponent(
      text: "${gameRef.slotMachine.win}",
      textRenderer: textPaint,
      size: Vector2(100, positionComponent.size.y),
      position: Vector2(spriteComponent.size.x + 5.0, 0),
    );
    // winTextBox = TextBoxComponent(
    //   text: "${gameRef.slotMachine.win}",
    //   size: Vector2(100, positionComponent.size.y),
    //   position: Vector2(spriteComponent.size.x, 0),
    // );
    positionComponent.add(spriteComponent);
    positionComponent.add(winTextBox!);
    component.add(positionComponent);
    return;
  }

  /// 設置下注框
  Future<void> _setupBetTextBox({required Component component}) async {
    final positionComponent = PositionComponent(
      size: Vector2((bottomBarSize!.x - innerSpacing * 2) / 2, (bottomBarSize!.y - innerSpacing * 2) / 3),
      position: Vector2(innerSpacing, (bottomBarSize!.y - innerSpacing * 2) / 3 * 1 + innerSpacing),
    );
    final sprite = await Sprite.load('game/bet_text.png');
    final spriteSize = Vector2(54.0, 26.0);
    final spriteComponent = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      position: Vector2(0, (positionComponent.size.y - spriteSize.y) / 2),
    );
    betTextBox = TextComponent(
      text: "${gameRef.slotMachine.bet}",
      textRenderer: textPaint,
      size: Vector2(100, positionComponent.size.y),
      position: Vector2(spriteComponent.size.x + 5.0, 0),
    );
    // betTextBox = TextBoxComponent(
    //   text: "${gameRef.slotMachine.bet}",
    //   size: Vector2(100, positionComponent.size.y),
    //   position: Vector2(spriteComponent.size.x, 0),
    // );
    positionComponent.add(spriteComponent);
    positionComponent.add(betTextBox!);
    component.add(positionComponent);
    return;
  }

  /// 設置額度
  Future<void> _setupBalance({required Component component}) async {
    final positionComponent = PositionComponent(
      size: Vector2((bottomBarSize!.x - innerSpacing * 2) / 2, (bottomBarSize!.y - innerSpacing * 2) / 3),
      position: Vector2(innerSpacing, (bottomBarSize!.y - innerSpacing * 2) / 3 * 2 + innerSpacing),
    );
    final sprite = await Sprite.load('game/balance_text.png');
    final spriteSize = Vector2(124.0, 26.0);
    final spriteComponent = SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      position: Vector2(0, (positionComponent.size.y - spriteSize.y) / 2),
    );
    balanceTextBox = TextComponent(
      text: "${gameRef.gameBalance}",
      textRenderer: textPaint,
      size: Vector2(100, positionComponent.size.y),
      position: Vector2(spriteComponent.size.x + 5.0, 0),
    );
    // balanceTextBox = TextBoxComponent(
    //   text: "${gameRef.slotMachine.balance}",
    //   size: Vector2(100, positionComponent.size.y),
    //   position: Vector2(spriteComponent.size.x, 0),
    // );
    positionComponent.add(spriteComponent);
    positionComponent.add(balanceTextBox!);
    component.add(positionComponent);
    return;
  }

  /// 進行得分動畫
  void showWin({required int win}) async {
    winTextBox!.text = "$win";

    if (win > 0) {
      effectClickBounce(component: winTextBox!);

      final sprite = await Sprite.load('game/win_frame.png');
      final spriteSize = Vector2(size.x * 0.5, (size.x * 0.5 / 297) * 131);
      winDialog = SpriteComponent(
        sprite: sprite,
        size: spriteSize,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
      winDialog!.add(TextComponent(
        text: "$win",
        textRenderer: TextPaint(
          style: GoogleFonts.abel(
            fontSize: 45.0,
            color: Colors.white,
          ),
          // style: const TextStyle(
          //   fontSize: 45.0,
          //   fontFamily: 'Awesome Font',
          //   color: Colors.white,
          // ),
        ),
        size: Vector2(winDialog!.size.x / 2, winDialog!.size.y / 2),
        position: Vector2(winDialog!.size.x / 2, winDialog!.size.y * 0.65),
        anchor: Anchor.center,
      ));
      add(winDialog!);
      effectClickBounce(component: winDialog!);

      // 2秒後移除
      Future.delayed(const Duration(milliseconds: 1500), () {
        winDialog!.removeFromParent();
      });
    }
  }

  /// 進行下注動畫
  void showBet({required int bet}) {
    betTextBox!.text = "$bet";
    effectClickBounce(component: betTextBox!);
  }

  /// 進行餘額動畫
  void showBalance({required int balance}) {
    balanceTextBox!.text = "$balance";
    effectClickBounce(component: balanceTextBox!);
  }

  /// 進行外連提示彈窗
  Future<void> showLinkTipsDialog({required String text, required String linkUrl}) async {
    // print("showLinkTipsDialog~~~ text: $text, linkUrl: $linkUrl");
    if (linkTipsDialog == null) {
      final sprite = await Sprite.load('game/gold_frame.png');
      final spriteSize = Vector2(694.0, 190.0);
      final spritePosition = Vector2(size.x / 2, size.y / 2);
      linkTipsDialog = SlotGameLinkTipsDialog(
        sprite: sprite,
        position: spritePosition,
        size: spriteSize,
        text: text,
        linkUrl: linkUrl,
      );
      add(linkTipsDialog!);
      return;
    }
  }

  /// 點擊回彈
  void effectClickBounce({required Component component}) {
    EffectController sineEffectController = SineEffectController(period: 0.6);
    int repeatCount = 1;
    EffectController repeatedEffectController = RepeatedEffectController(sineEffectController, repeatCount);
    Effect effect = ScaleEffect.by(
      Vector2.all(1.5),
      repeatedEffectController,
      onComplete: () {
        // print("effectBounceAfterScale Finish!!!");
      },
    );
    component.add(effect);
  }
}
