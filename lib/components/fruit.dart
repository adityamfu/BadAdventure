import 'dart:async';
import 'package:bad_adventure/bad_adventure.dart';
import 'package:flame/components.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<BadAdventure> {
  late final String fruit;
  Fruit({this.fruit = 'Apple', position, size})
      : super(position: position, size: size);

  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
}
