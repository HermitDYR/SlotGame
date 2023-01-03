import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hawaiian_game_slot/slot_game/slot_game_control_menu.dart';
import 'package:hawaiian_game_slot/slot_game/slot_machine.dart';
import 'package:hawaiian_game_slot/slot_game_config.dart';

class SlotGame extends FlameGame with HasTappables, HasCollisionDetection {
  /// 相機場景大小
  final Vector2 cameraFixedViewPort = Vector2(900.0, 1334.0);

  /// 背景音樂撥放器
  AudioPlayer? bgmAudioPlayer;

  /// 音樂撥放器快取
  AudioCache? musicCache;

  /// 音樂撥放器
  AudioPlayer? instance;

  /// 老虎機
  late SlotMachine slotMachine;

  /// 老虎機遊戲控制選單
  late SlotGameControlMenu slotGameControlMenu;

  /// 遊戲玩家編號
  String gameUserId = "Demo01";

  /// 遊戲玩家餘額
  int gameBalance = 10000;

  /// 遊戲最大遊戲回合數
  int gameMaxRound = 100;

  /// 遊戲中獎機率(0.0~1.0)
  double gameRTP = 0.5;

  /// 遊戲外連網址
  String gameLinkUrl = "https://google.com";

  @override
  Future<void> onLoad() async {
    // 取得 App 畫面寬高
    // final double screenWidth = MediaQueryData.fromWindow(ui.window).size.width;
    // final double screenHeight = MediaQueryData.fromWindow(ui.window).size.height;
    // print("screenWidth: ${screenWidth}, screenHeight: ${screenHeight}");

    camera.viewport = FixedResolutionViewport(cameraFixedViewPort);

    // 設置遊戲(依據Web網址參數)
    _setupGameFromCurrentWebUrlInfo();

    // 設置背景音樂
    await _setupBGM();

    // 設置背景填充
    await _setupBgFill();

    // 設定老虎機
    _setupSlotMachine();

    // 設置老虎機遮罩
    await _setupMask();

    // 設置老虎機上方欄位
    await _setupTopBar();

    // 設置老虎機下方欄位
    await _setupBottomBar();

    // 設置老虎機遊戲控制選單
    _setupSlotGameControllerMenu();
  }

  /// 設置遊戲(依據Web網址參數)
  /// - 舉例: http://localhost:62230/?balance=3000&maxRound=6&rtp=1&linkUrl=https://www.youtube.com
  void _setupGameFromCurrentWebUrlInfo() {
    print("_setupGameFromCurrentWebUrlInfo~~~~~");
    print("Uri.base: ${Uri.base.toString()}");
    print("Uri.base.origin: ${Uri.base.origin}");
    print("Uri.base.queryParameters: ${Uri.base.queryParameters}");
    // 網址參數
    final parameterKeys = [
      "userId", // 玩家編號
      "balance", // 玩家餘額
      "maxRound", // 遊戲最大回合數
      "rtp", // 遊戲中獎機率
      "linkUrl", // 遊戲外連網址
    ];
    for (int i = 0; i < parameterKeys.length; i++) {
      final key = parameterKeys[i];
      var value = Uri.base.queryParameters[key];
      // 確認Web參數是否正確並設置遊戲參數
      _checkParameterKeyValueToSettingGame(key: key, value: value);
    }
  }

  /// 確認Web參數是否正確並設置遊戲參數
  void _checkParameterKeyValueToSettingGame({required String key, required String? value}) {
    if (key == "userId" && value != null && value.isNotEmpty) {
      gameUserId = value;
      print("SlotGame >> gameUserId: $gameUserId");
    } else if (key == "balance" && value != null && value.isNotEmpty) {
      gameBalance = int.parse(value);
      print("SlotGame >> gameBalance: $gameBalance");
    } else if (key == "maxRound" && value != null && value.isNotEmpty) {
      gameMaxRound = int.parse(value);
      print("SlotGame >> gameMaxRound: $gameMaxRound");
    } else if (key == "rtp" && value != null && value.isNotEmpty) {
      gameRTP = double.parse(value);
      print("SlotGame >> gameRTP: $gameRTP");
    } else if (key == "linkUrl" && value != null && value.isNotEmpty) {
      gameLinkUrl = value.toString();
      print("SlotGame >> gameLinkUrl: $gameLinkUrl");
    } else {
      print("SlotGame >> _checkValueToSettingGame NotFind key: $key & value: $value");
    }
  }

  /// 設置背景音樂
  Future<void> _setupBGM() async {
    bgmAudioPlayer = AudioPlayer();
    await bgmAudioPlayer!.audioCache.load('audio/bgm.mp3');
    await bgmAudioPlayer!.setPlayerMode(PlayerMode.mediaPlayer);
    await bgmAudioPlayer!.setVolume(0.5);
    return;
  }

  /// 設置背景填充
  Future<void> _setupBgFill() async {
    add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill));

    final sprite = await Sprite.load('game/game_background.jpg');
    add(SpriteComponent(sprite: sprite, size: cameraFixedViewPort));
    return;
  }

  /// 設定老虎機
  void _setupSlotMachine() async {
    var barWidth = (cameraFixedViewPort.x * 0.8) / SlotGameConfig.barCount;
    var position = Vector2(cameraFixedViewPort.x / 2, cameraFixedViewPort.y / 2.2);
    var size = Vector2(barWidth * SlotGameConfig.barCount, barWidth * SlotGameConfig.barItemCount);
    slotMachine = SlotMachine(
      barWidth: barWidth,
      barCount: SlotGameConfig.barCount,
      barItemCount: SlotGameConfig.barItemCount,
      position: position,
      size: size,
    );
    add(slotMachine);
  }

  /// 設置老虎機遊戲控制選單
  void _setupSlotGameControllerMenu() {
    // var position = Vector2(cameraFixedViewPort.x / 2, cameraFixedViewPort.y * 0.885);
    // var size = Vector2(cameraFixedViewPort.x * 0.9, cameraFixedViewPort.y * 0.1);
    var position = Vector2(cameraFixedViewPort.x / 2, cameraFixedViewPort.y / 2);
    var size = Vector2(cameraFixedViewPort.x * 0.9, cameraFixedViewPort.y * 0.9);
    slotGameControlMenu = SlotGameControlMenu(position: position, size: size);
    add(slotGameControlMenu);
  }

  /// 設置老虎機遮罩
  Future<void> _setupMask() async {
    final sprite = await Sprite.load('game/game_background_mask.png');
    var width = cameraFixedViewPort.x;
    var height = cameraFixedViewPort.y;
    var x = size.x / 2;
    var y = size.y / 2;
    add(SpriteComponent(
      sprite: sprite,
      size: Vector2(width, height),
      position: Vector2(x, y),
      anchor: Anchor.center,
    ));
    return;
  }

  /// 設置老虎機上方欄位
  Future<void> _setupTopBar() async {
    final sprite = await Sprite.load('game/gold_top_bar.png');
    var scaleWidth = size.x * 0.8;
    var scaleHeight = scaleWidth * (230 / 790);
    var x = size.x / 2;
    var y = size.y * 0.15;
    add(SpriteComponent(
      sprite: sprite,
      size: Vector2(scaleWidth, scaleHeight),
      position: Vector2(x, y),
      anchor: Anchor.center,
    ));
    return;
  }

  /// 設置老虎機下方欄位
  Future<void> _setupBottomBar() async {
    final sprite = await Sprite.load('game/gold_bottom_bar.png');
    var scaleWidth = size.x * 0.8;
    var scaleHeight = scaleWidth * (230 / 790);
    var x = size.x / 2;
    var y = size.y * 0.725;
    add(SpriteComponent(
      sprite: sprite,
      size: Vector2(scaleWidth, scaleHeight),
      position: Vector2(x, y),
      anchor: Anchor.center,
    ));
    return;
  }
}
