import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Represents a bullet received from the server (shot by any player)
class RemoteBullet extends CircleComponent {
  final String id;
  final String ownerId;
  double targetX;
  double targetY;
  
  static const double lerpSpeed = 20.0;

  RemoteBullet({
    required this.id,
    required this.ownerId,
    required double x,
    required double y,
    required double rotation,
  })  : targetX = x,
        targetY = y,
        super(
          radius: 4,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.yellow,
          position: Vector2(x, y),
        ) {
    angle = rotation;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Smooth interpolation
    position.x += (targetX - position.x) * lerpSpeed * dt;
    position.y += (targetY - position.y) * lerpSpeed * dt;
  }

  void updateFromServer(double x, double y, double rotation) {
    targetX = x;
    targetY = y;
    angle = rotation;
  }
}
