import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import 'player.dart';
import '../../config.dart';

class Grenade extends CircleComponent with HasGameRef {
  final Vector2 direction;
  final Player thrower;
  double _timer = 0;
  bool _exploded = false;
  static final _paint = Paint()..color = Colors.orange;

  Grenade({required Vector2 position, required this.direction, required this.thrower})
      : super(radius: 8, position: position, paint: _paint, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (_exploded) return;
    
    position += direction * cfg.grenadeSpeed * dt;
    _timer += dt;
    
    if (_timer > cfg.grenadeDelay - 0.5) {
      paint.color = (_timer * 10).toInt() % 2 == 0 ? Colors.red : Colors.orange;
    }
    
    if (_timer >= cfg.grenadeDelay) _explode();
  }

  void _explode() {
    _exploded = true;
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    for (final enemy in enemies) {
      if (enemy.position.distanceTo(position) < cfg.grenadeRadius) {
        enemy.removeFromParent();
        thrower.addScore(cfg.grenadeKillScore);
      }
    }
    
    final explosion = CircleComponent(
      radius: cfg.grenadeRadius,
      paint: Paint()..color = Colors.orange.withOpacity(0.6),
      anchor: Anchor.center,
      position: position.clone(),
    );
    parent?.add(explosion);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (explosion.isMounted) explosion.paint.color = Colors.red.withOpacity(0.4);
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (explosion.isMounted) explosion.paint.color = Colors.red.withOpacity(0.2);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (explosion.isMounted) explosion.removeFromParent();
    });
    
    removeFromParent();
  }
}
