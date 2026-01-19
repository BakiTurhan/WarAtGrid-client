import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'world.dart';
import 'fog_of_war.dart';
import '../../config.dart';

class Enemy extends CircleComponent with HasGameRef {
  static final _visiblePaint = Paint()..color = Colors.red;
  static final _hiddenPaint = Paint()..color = Colors.transparent;
  
  final Player player;
  bool _isAlerted = false;

  Enemy({required this.player, required Vector2 position})
      : super(
          radius: cfg.enemyRadius, 
          position: position, 
          anchor: Anchor.center, 
          paint: _visiblePaint,
        );

  @override
  void update(double dt) {
    super.update(dt);
    
    final fogOfWar = parent?.children.whereType<FogOfWar>().firstOrNull;
    final playerCanSeeMe = fogOfWar?.isVisible(position) ?? true;
    
    if (playerCanSeeMe && !_isAlerted) _isAlerted = true;
    paint = playerCanSeeMe ? _visiblePaint : _hiddenPaint;
    
    final distToPlayer = player.position.distanceTo(position);
    if (distToPlayer < player.radius + radius) {
      player.takeDamage(cfg.enemyContactDamage);
    }
    
    final direction = player.position - position;
    if (direction.length > 5) {
      direction.normalize();
      final gameWorld = parent?.children.whereType<GameWorld>().firstOrNull;
      
      if (_isAlerted) {
        final moveX = Vector2(direction.x * cfg.enemySpeed * dt, 0);
        final moveY = Vector2(0, direction.y * cfg.enemySpeed * dt);
        final newPos = position + direction * cfg.enemySpeed * dt;
        if (gameWorld == null || !gameWorld.collidesWithObstacle(newPos, radius)) {
          position = newPos;
        } else {
          final newPosX = position + moveX;
          if (gameWorld == null || !gameWorld.collidesWithObstacle(newPosX, radius)) position = newPosX;
          final newPosY = position + moveY;
          if (gameWorld == null || !gameWorld.collidesWithObstacle(newPosY, radius)) position = newPosY;
        }
      } else {
        final newPos = position + direction * cfg.enemySpeed * dt;
        if (gameWorld == null || !gameWorld.collidesWithObstacle(newPos, radius)) position = newPos;
      }
    }
    
    position.x = position.x.clamp(cfg.wallThickness + radius, cfg.worldWidth - cfg.wallThickness - radius);
    position.y = position.y.clamp(cfg.wallThickness + radius, cfg.worldHeight - cfg.wallThickness - radius);
  }
}
