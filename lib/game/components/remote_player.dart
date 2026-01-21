import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Represents another player received from the server
class RemotePlayer extends PositionComponent {
  final String id;
  String name;
  double targetX;
  double targetY;
  double targetRotation;
  
  static const double lerpSpeed = 15.0;
  static const double playerRadius = 20.0;

  late CircleComponent _body;
  late RectangleComponent _gunBarrel;
  late TextComponent _nameLabel;
  double _currentRotation = 0;

  RemotePlayer({
    required this.id,
    required this.name,
    required double x,
    required double y,
    required double rotation,
  })  : targetX = x,
        targetY = y,
        targetRotation = rotation,
        super(
          position: Vector2(x, y),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Body (doesn't rotate)
    _body = CircleComponent(
      radius: playerRadius,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.red.shade400,
    );
    add(_body);
    
    // Gun barrel (rotates with player direction)
    _gunBarrel = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(playerRadius * 1.2, 8),
      anchor: Anchor.centerLeft,
      paint: Paint()..color = Colors.white70,
    );
    add(_gunBarrel);
    
    // Name label (stays upright)
    _nameLabel = TextComponent(
      text: name,
      position: Vector2(0, -playerRadius - 12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_nameLabel);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Smooth position interpolation
    position.x += (targetX - position.x) * lerpSpeed * dt;
    position.y += (targetY - position.y) * lerpSpeed * dt;
    
    // Smooth rotation interpolation (only for gun barrel)
    // Handle angle wrapping for shortest path interpolation
    double diff = targetRotation - _currentRotation;
    while (diff < -pi) diff += 2 * pi;
    while (diff > pi) diff -= 2 * pi;
    
    _currentRotation += diff * lerpSpeed * dt;
    _gunBarrel.angle = _currentRotation;
  }

  void updateFromServer(double x, double y, double rotation) {
    targetX = x;
    targetY = y;
    targetRotation = rotation;
  }
}
