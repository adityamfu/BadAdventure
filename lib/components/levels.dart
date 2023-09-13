import 'dart:async';
import 'package:bad_adventure/bad_adventure.dart';
import 'package:bad_adventure/components/background_tile.dart';
import 'package:bad_adventure/components/fruit.dart';
import 'package:bad_adventure/components/parts_block.dart';
import 'package:bad_adventure/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<BadAdventure> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<PartsBlock> partsBlock = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    // _scrollingBackground();
    _spawningObject();
    _addParts();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    const tileSize = 64;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          final backgorundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(x * tileSize, y * tileSize - tileSize),
          );

          add(backgorundTile);
        }
      }
    }
  }

  void _spawningObject() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case ' Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
          default:
        }
      }
    }
  }

  void _addParts() {
    final partsObject = level.tileMap.getLayer<ObjectGroup>('Parts');

    if (partsObject != null) {
      for (final parts in partsObject.objects) {
        switch (parts.class_) {
          case 'Platfrom':
            final platform = PartsBlock(
              position: Vector2(parts.x, parts.y),
              size: Vector2(parts.width, parts.height),
              isPlatfrom: true,
            );
            partsBlock.add(platform);
            add(platform);
            break;
          default:
            final block = PartsBlock(
              position: Vector2(parts.x, parts.y),
              size: Vector2(parts.width, parts.height),
            );
            partsBlock.add(block);
            add(block);
        }
      }
    }
    player.partsBlock = partsBlock;
  }
}
