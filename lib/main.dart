import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'bad_adventure.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  BadAdventure game = BadAdventure();
  runApp(
    GameWidget(game: kDebugMode ? BadAdventure() : game),
  );
}