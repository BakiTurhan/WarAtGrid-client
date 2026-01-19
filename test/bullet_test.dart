import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:waratgrid/game/components/bullet.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Bullet Initialization', () {
    test('Creates with correct radius', () {
      final bullet = Bullet(
        position: Vector2.zero(),
        direction: Vector2(1, 0),
      );
      expect(bullet.radius, cfg.bulletRadius);
    });

    test('Stores direction correctly', () {
      final direction = Vector2(1, 0).normalized();
      final bullet = Bullet(
        position: Vector2.zero(),
        direction: direction,
      );
      expect(bullet.direction.x, closeTo(1, 0.01));
      expect(bullet.direction.y, closeTo(0, 0.01));
    });
  });

  group('Bullet Movement', () {
    test('Moves in correct direction on update', () {
      final bullet = Bullet(
        position: Vector2(100, 100),
        direction: Vector2(1, 0),
      );

      // Simulate 1 second
      bullet.update(1.0);

      // Should move bulletSpeed pixels to the right
      expect(bullet.position.x, closeTo(100 + cfg.bulletSpeed, 1));
      expect(bullet.position.y, closeTo(100, 1));
    });

    test('Moves diagonally correctly', () {
      final direction = Vector2(1, 1).normalized();
      final bullet = Bullet(
        position: Vector2(0, 0),
        direction: direction,
      );

      bullet.update(1.0);

      // Both X and Y should increase
      expect(bullet.position.x, greaterThan(0));
      expect(bullet.position.y, greaterThan(0));
    });

    test('Speed matches config', () {
      final bullet = Bullet(
        position: Vector2(0, 0),
        direction: Vector2(1, 0),
      );

      final startX = bullet.position.x;
      bullet.update(0.5); // Half second

      expect(bullet.position.x - startX, closeTo(cfg.bulletSpeed * 0.5, 1));
    });
  });
}
