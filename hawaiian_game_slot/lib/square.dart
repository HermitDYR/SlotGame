import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';

class Square extends PositionComponent with Tappable {
  static const speed = 0.25;
  static const squareSize = 128.0;

  static Paint white = BasicPalette.white.paint();
  static Paint red = BasicPalette.red.paint();
  static Paint blue = BasicPalette.blue.paint();

  Square(Vector2 position) : super(position: position);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), white);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 3, 3), red);
    canvas.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), blue);
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt;
    angle %= 2 * math.pi;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size.setValues(squareSize, squareSize);
    anchor = Anchor.center;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    removeFromParent();
    info.handled = true;
    return true;
  }
}