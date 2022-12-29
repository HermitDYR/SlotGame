import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hawaiian_game_slot/slot_game.dart';
import 'package:hawaiian_game_slot/slot_game/slot_game_control_menu/slot_game_dialog_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SlotGameLinkTipsDialog extends SpriteComponent with HasGameRef<SlotGame> {
  /// 文字物件
  TextComponent? _textComponent;

  /// 文字
  String? text;

  /// 外連網址
  String? linkUrl;

  /// 左遊戲彈窗按鈕
  SlotGameDialogButton? leftDialogButton;

  /// 右遊戲彈窗按鈕
  SlotGameDialogButton? rightDialogButton;

  /// 老虎機遊戲外連提示彈窗
  SlotGameLinkTipsDialog({
    required Sprite sprite,
    required Vector2? position,
    required Vector2? size,
    this.text,
    this.linkUrl,
  }) : super(sprite: sprite, position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() {
    // 設置文字物件
    _setupTextComponent();

    // 設置左遊戲彈窗按鈕
    _setupLeftButton();

    // 設置右遊戲彈窗按鈕
    // _setupRightButton();

    return super.onLoad();
  }

  /// 設置文字物件
  void _setupTextComponent() {
    _textComponent = TextComponent(
      text: text ?? "?",
      textRenderer: TextPaint(
        style: GoogleFonts.abel(
            fontSize: 30.0,
            color: Colors.white,
        ),
        // style: const TextStyle(
        //   fontSize: 30.0,
        //   fontFamily: 'Awesome Font',
        //   color: Colors.white,
        // ),
      ),
      size: Vector2(size.x * 0.8, size.y * 0.8),
      position: Vector2(size.x / 2, size.y * 0.25),
      anchor: Anchor.center,
    );
    add(_textComponent!);
  }

  /// 設置左遊戲彈窗按鈕
  Future<void> _setupLeftButton() async {
    final sprite = await Sprite.load('game/dialog_button_green.png');
    final spriteSize = Vector2(size.x / 4, size.x / 4 / 348.0 * 113.0);
    // final spritePosition = Vector2(size.x / 4 * 1, size.y * 0.85 - spriteSize.y / 2); // 左邊
    final spritePosition = Vector2(size.x / 2, size.y * 0.85 - spriteSize.y / 2); // 中間
    leftDialogButton = SlotGameDialogButton(
      sprite: sprite,
      size: spriteSize,
      position: spritePosition,
      onTap: onTapLeftButton,
    );
    leftDialogButton!.add(TextComponent(
      text: "YES",
      textRenderer: TextPaint(
        style: GoogleFonts.abel(
          fontSize: 30.0,
          color: Colors.white,
        ),
        // style: const TextStyle(
        //   fontSize: 30.0,
        //   fontFamily: 'Awesome Font',
        //   color: Colors.white,
        // ),
      ),
      size: Vector2(spriteSize.x, spriteSize.y),
      position: Vector2(spriteSize.x / 2, spriteSize.y / 2),
      anchor: Anchor.center,
    ));
    add(leftDialogButton!);
    return;
  }

  /// 設置右遊戲彈窗按鈕
  Future<void> _setupRightButton() async {
    final sprite = await Sprite.load('game/dialog_button_blue.png');
    final spriteSize = Vector2(size.x / 4, size.x / 4 / 348.0 * 113.0);
    final spritePosition = Vector2(size.x / 4 * 3, size.y * 0.85 - spriteSize.y / 2); // 右邊
    rightDialogButton = SlotGameDialogButton(
      sprite: sprite,
      size: spriteSize,
      position: spritePosition,
      onTap: onTapRightButton,
    );
    rightDialogButton!.add(TextComponent(
      text: "NO",
      textRenderer: TextPaint(
        style: GoogleFonts.abel(
          fontSize: 30.0,
          color: Colors.white,
        ),
        // style: const TextStyle(
        //   fontSize: 30.0,
        //   fontFamily: 'Awesome Font',
        //   color: Colors.white,
        // ),
      ),
      size: Vector2(spriteSize.x, spriteSize.y),
      position: Vector2(spriteSize.x / 2, spriteSize.y / 2),
      anchor: Anchor.center,
    ));
    add(rightDialogButton!);
    return;
  }

  /// 點擊左遊戲彈窗按鈕
  void onTapLeftButton() {
    if (linkUrl != null) {
      if (linkUrl!.contains("https://")) {
        linkUrl = linkUrl!.replaceAll("https://", "");
      }
      // 外部連結瀏覽器
      _launchInBrowser(Uri(scheme: 'https', host: linkUrl));
    }
  }

  /// 點擊右遊戲彈窗按鈕
  void onTapRightButton() {
    gameRef.slotGameControlMenu.slotGameSpinButton!.setIsSpin(false);
    gameRef.slotGameControlMenu.linkTipsDialog = null;
    gameRef.slotMachine.gameRound = 0;
    removeFromParent();
  }

  /// 外部連結瀏覽器
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
