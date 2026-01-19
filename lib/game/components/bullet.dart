import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import 'world.dart';
import '../../config.dart';

class Bullet extends CircleComponent with HasGameRef<FlameGame> {
  final Vector2 direction;
  static final _paint = Paint()..color = Colors.yellow;

  Bullet({required Vector2 position, required this.direction})
      : super(radius: cfg.bulletRadius, position: position, paint: _paint, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    
    final newPos = position + direction * cfg.bulletSpeed * dt;
    final gameWorld = parent?.children.whereType<GameWorld>().firstOrNull;
    if (gameWorld != null && gameWorld.collidesWithObstacle(newPos, radius)) {
      removeFromParent();
      return;
    }
    
    position = newPos;
    if (position.x < 0 || position.x > cfg.worldWidth || position.y < 0 || position.y > cfg.worldHeight) {
      removeFromParent();
      return;
    }
    
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    for (final enemy in enemies) {
      if (enemy.containsPoint(position)) {
        enemy.removeFromParent();
        enemy.player.addScore(cfg.bulletKillScore);
        removeFromParent();
        break; 
      }
    }
  }
}
