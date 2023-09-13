import 'dart:async';
import 'package:bad_adventure/bad_adventure.dart';
import 'package:bad_adventure/components/player_hitbox.dart';
import 'package:bad_adventure/components/parts_block.dart';
import 'package:bad_adventure/components/unit.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

enum PlayerState { idle, running, jump, fall }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<BadAdventure>, KeyboardHandler {
  String character;
  Player({
    position,
    this.character = 'Mask Dude',
  }) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;

  final double stepTime = 0.05;
  final double _gravity = 9.8;
  final double _jump = 460;
  final double _terminalVelocity = 300;

  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isGround = false;
  bool isJump = false;
  List<PartsBlock> partsBlock = [];
  PlayerHitBox hitbox = PlayerHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalParts();
    _setGravity(dt);
    _checkVerticalParts();
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKey = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKey = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKey ? -1 : 0;
    horizontalMovement += isRightKey ? 1 : 0;

    isJump = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpAnimation = _spriteAnimation('Jump', 1);
    fallAnimation = _spriteAnimation('Fall', 1);

    // animation list
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
    };

    // set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (isJump && isGround) _playerJump(dt);

    // optional gravity
    // if (velocity.y > _gravity) isGround = false;

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    if (velocity.y > _gravity) playerState = PlayerState.fall;

    if (velocity.y < 0) playerState = PlayerState.jump;

    current = playerState;
  }

  void _checkHorizontalParts() {
    for (final block in partsBlock) {
      if (!block.isPlatfrom) {
        if (checkParts(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _setGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jump, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalParts() {
    for (final block in partsBlock) {
      if (block.isPlatfrom) {
        if (checkParts(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isGround = true;
            break;
          }
        }
      } else {
        if (checkParts(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            // isGround = true;
            // break;
          }
        }
      }
    }
  }

  void _playerJump(double dt) {
    velocity.y = -_jump;
    position.y += velocity.y * dt;
    isGround = false;
    isJump = false;
  }
}
