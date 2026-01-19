import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../config.dart';

class GameWorld extends Component with HasGameRef {
  final List<RectangleComponent> walls = [];
  final List<RectangleComponent> blocks = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_GridFloor());
    _createBoundaries();
    _createObstacles();
  }

  void _createBoundaries() {
    final wallPaint = Paint()..color = Colors.grey.shade800;
    final w = cfg.worldWidth;
    final h = cfg.worldHeight;
    final t = cfg.wallThickness;

    final topWall = RectangleComponent(position: Vector2(0, 0), size: Vector2(w, t), paint: wallPaint);
    walls.add(topWall); add(topWall);

    final bottomWall = RectangleComponent(position: Vector2(0, h - t), size: Vector2(w, t), paint: wallPaint);
    walls.add(bottomWall); add(bottomWall);

    final leftWall = RectangleComponent(position: Vector2(0, 0), size: Vector2(t, h), paint: wallPaint);
    walls.add(leftWall); add(leftWall);

    final rightWall = RectangleComponent(position: Vector2(w - t, 0), size: Vector2(t, h), paint: wallPaint);
    walls.add(rightWall); add(rightWall);
  }

  void _createObstacles() {
    final blockPaint = Paint()..color = Colors.brown.shade700;
    final random = Random(42);
    final w = cfg.worldWidth;
    final h = cfg.worldHeight;
    final t = cfg.wallThickness;

    for (int i = 0; i < cfg.obstacleCount; i++) {
      final x = t + random.nextDouble() * (w - 200);
      final y = t + random.nextDouble() * (h - 200);
      final bw = 50.0 + random.nextDouble() * 100;
      final bh = 50.0 + random.nextDouble() * 100;

      if ((x - w / 2).abs() < 200 && (y - h / 2).abs() < 200) continue;

      final block = RectangleComponent(position: Vector2(x, y), size: Vector2(bw, bh), paint: blockPaint);
      blocks.add(block); add(block);
    }
  }

  bool collidesWithObstacle(Vector2 position, double radius) {
    for (final wall in walls) if (_circleRectCollision(position, radius, wall)) return true;
    for (final block in blocks) if (_circleRectCollision(position, radius, block)) return true;
    return false;
  }

  bool _circleRectCollision(Vector2 circlePos, double radius, RectangleComponent rect) {
    final closestX = circlePos.x.clamp(rect.position.x, rect.position.x + rect.size.x);
    final closestY = circlePos.y.clamp(rect.position.y, rect.position.y + rect.size.y);
    return (circlePos - Vector2(closestX, closestY)).length < radius;
  }
}

class _GridFloor extends Component with HasGameRef {
  @override
  void render(Canvas canvas) {
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1..style = PaintingStyle.stroke;
    for (double x = 0; x <= cfg.worldWidth; x += cfg.gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, cfg.worldHeight), gridPaint);
    }
    for (double y = 0; y <= cfg.worldHeight; y += cfg.gridSize) {
      canvas.drawLine(Offset(0, y), Offset(cfg.worldWidth, y), gridPaint);
    }
  }
}
