import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'player.dart';
import 'world.dart';
import '../../config.dart';

class FogOfWar extends PositionComponent with HasGameRef {
  final Player player;
  FogOfWar({required this.player});
  
  bool isVisible(Vector2 point) {
    final gameWorld = parent?.children.whereType<GameWorld>().firstOrNull;
    if (gameWorld == null) return true;
    final dist = player.position.distanceTo(point);
    if (dist > cfg.viewRadius) return false;
    return !_isLineBlocked(player.position, point, gameWorld);
  }
  
  bool _isLineBlocked(Vector2 from, Vector2 to, GameWorld gameWorld) {
    final dir = to - from;
    final dist = dir.length;
    if (dist < 1) return false;
    final normalizedDir = dir.normalized();
    for (final rect in [...gameWorld.walls, ...gameWorld.blocks]) {
      final hitDist = _rayBoxIntersect(from, normalizedDir, rect.position, rect.size);
      if (hitDist != null && hitDist > 0 && hitDist < dist - 1) return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final playerPos = player.position;
    final worldRect = Rect.fromLTWH(0, 0, cfg.worldWidth, cfg.worldHeight);
    final fullPath = Path()..addRect(worldRect);
    final visibleCircle = Path()..addOval(Rect.fromCircle(center: Offset(playerPos.x, playerPos.y), radius: cfg.viewRadius));
    final fogPath = Path.combine(PathOperation.difference, fullPath, visibleCircle);
    canvas.drawPath(fogPath, Paint()..color = Colors.black.withOpacity(0.95));
  }

  double? _rayBoxIntersect(Vector2 rayOrigin, Vector2 rayDir, Vector2 boxPos, Vector2 boxSize) {
    final boxMin = boxPos;
    final boxMax = boxPos + boxSize;
    double tmin = 0.0, tmax = double.infinity;
    
    if (rayDir.x.abs() < 0.0001) {
      if (rayOrigin.x < boxMin.x || rayOrigin.x > boxMax.x) return null;
    } else {
      double t1 = (boxMin.x - rayOrigin.x) / rayDir.x;
      double t2 = (boxMax.x - rayOrigin.x) / rayDir.x;
      if (t1 > t2) { final temp = t1; t1 = t2; t2 = temp; }
      tmin = max(tmin, t1); tmax = min(tmax, t2);
      if (tmin > tmax) return null;
    }
    
    if (rayDir.y.abs() < 0.0001) {
      if (rayOrigin.y < boxMin.y || rayOrigin.y > boxMax.y) return null;
    } else {
      double t1 = (boxMin.y - rayOrigin.y) / rayDir.y;
      double t2 = (boxMax.y - rayOrigin.y) / rayDir.y;
      if (t1 > t2) { final temp = t1; t1 = t2; t2 = temp; }
      tmin = max(tmin, t1); tmax = min(tmax, t2);
      if (tmin > tmax) return null;
    }
    
    return tmin > 0 ? tmin : (tmax > 0 ? tmax : null);
  }
}
