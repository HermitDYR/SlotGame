import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hawaiian_game_slot/slot_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 填滿全畫面
  await Flame.device.fullScreen();
  // 螢幕垂直
  await Flame.device.setPortrait();

  // 遊戲
  final game = SlotGame();
  runApp(GameWidget(game: game));
}

