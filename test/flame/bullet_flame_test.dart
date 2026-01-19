import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/components/bullet.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Bullet Flame Component Tests', () {
    testWithFlameGame(
      'Bullet updates position correctly',
      (game) async {
        final bullet = Bullet(
          position: Vector2(100, 100),
          direction: Vector2(1, 0),
        );
        await game.ensureAdd(bullet);

        // Initial position
        expect(bullet.position.x, 100);

        // Simulate update
        game.update(0.1);

        // Should have moved right
        expect(bullet.position.x, greaterThan(100));
      },
    );

    testWithFlameGame(
      'Bullet moves at configured speed',
      (game) async {
        final bullet = Bullet(
          position: Vector2(0, 0),
          direction: Vector2(1, 0),
        );
        await game.ensureAdd(bullet);

        game.update(1.0); // 1 second

        expect(bullet.position.x, closeTo(cfg.bulletSpeed, 1));
      },
    );

    testWithFlameGame(
      'Bullet has correct radius',
      (game) async {
        final bullet = Bullet(
          position: Vector2.zero(),
          direction: Vector2(1, 0),
        );
        await game.ensureAdd(bullet);

        expect(bullet.radius, cfg.bulletRadius);
      },
    );

    testWithFlameGame(
      'Multiple bullets move independently',
      (game) async {
        final bullet1 = Bullet(
          position: Vector2(0, 0),
          direction: Vector2(1, 0), // Right
        );
        final bullet2 = Bullet(
          position: Vector2(0, 0),
          direction: Vector2(0, 1), // Down
        );

        await game.ensureAdd(bullet1);
        await game.ensureAdd(bullet2);

        game.update(0.5);

        // Bullet1 should move right
        expect(bullet1.position.x, greaterThan(0));
        expect(bullet1.position.y, closeTo(0, 1));

        // Bullet2 should move down
        expect(bullet2.position.x, closeTo(0, 1));
        expect(bullet2.position.y, greaterThan(0));
      },
    );
  });
}
