import 'dart:async';
import 'dart:ui';
import 'package:bad_adventure/levels/levels.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BadAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xff211f30);
  late final CameraComponent cam;
  final world = Level();

  @override
  FutureOr<void> onLoad() {
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);
    return super.onLoad();
  }
}
