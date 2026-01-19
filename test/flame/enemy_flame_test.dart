import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/components/enemy.dart';
import 'package:waratgrid/game/components/player.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Enemy Component Tests', () {
    testWithFlameGame(
      'Enemy creates with correct radius',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final enemy = Enemy(player: player, position: Vector2(200, 200));
        await game.ensureAdd(enemy);

        expect(enemy.radius, cfg.enemyRadius);
      },
    );

    testWithFlameGame(
      'Enemy mounts successfully',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final enemy = Enemy(player: player, position: Vector2(200, 200));
        await game.ensureAdd(enemy);

        expect(enemy.isMounted, true);
      },
    );

    testWithFlameGame(
      'Enemy moves toward player',
      (game) async {
        final player = Player();
        player.position = Vector2(500, 500);
        await game.ensureAdd(player);

        final enemy = Enemy(player: player, position: Vector2(100, 100));
        await game.ensureAdd(enemy);

        final startPos = enemy.position.clone();
        game.update(1.0);

        // Distance to player should decrease
        final startDist = startPos.distanceTo(player.position);
        final endDist = enemy.position.distanceTo(player.position);
        expect(endDist, lessThan(startDist));
      },
    );

    testWithFlameGame(
      'Enemy moves at configured speed',
      (game) async {
        final player = Player();
        player.position = Vector2(1000, 0); // Far right
        await game.ensureAdd(player);

        final enemy = Enemy(player: player, position: Vector2(0, 0));
        await game.ensureAdd(enemy);

        game.update(1.0);

        // Should have moved approximately enemySpeed pixels
        expect(enemy.position.x, closeTo(cfg.enemySpeed, 10));
      },
    );

    testWithFlameGame(
      'Multiple enemies can exist',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final enemy1 = Enemy(player: player, position: Vector2(100, 100));
        final enemy2 = Enemy(player: player, position: Vector2(200, 200));
        final enemy3 = Enemy(player: player, position: Vector2(300, 300));

        await game.ensureAdd(enemy1);
        await game.ensureAdd(enemy2);
        await game.ensureAdd(enemy3);

        expect(enemy1.isMounted, true);
        expect(enemy2.isMounted, true);
        expect(enemy3.isMounted, true);
      },
    );

    testWithFlameGame(
      'Enemy stays within world bounds',
      (game) async {
        final player = Player();
        player.position = Vector2(-1000, -1000); // Outside world
        await game.ensureAdd(player);

        final enemy = Enemy(player: player, position: Vector2(50, 50));
        await game.ensureAdd(enemy);

        game.update(10.0); // Long update

        // Enemy should be clamped to world bounds
        expect(enemy.position.x, greaterThanOrEqualTo(cfg.wallThickness + enemy.radius));
        expect(enemy.position.y, greaterThanOrEqualTo(cfg.wallThickness + enemy.radius));
      },
    );
  });

  group('Enemy Config Tests', () {
    test('Enemy config values are correct', () {
      expect(cfg.enemyRadius, 15.0);
      expect(cfg.enemySpeed, 100.0);
      expect(cfg.enemyContactDamage, 10.0);
      expect(cfg.enemySpawnInterval, 2.0);
      expect(cfg.meleeKillScore, 50);
    });

    test('Enemy speed can be modified', () {
      cfg.enemySpeed = 200.0;
      expect(cfg.enemySpeed, 200.0);
      cfg.resetToDefaults();
    });

    test('Enemy damage can be modified', () {
      cfg.enemyContactDamage = 25.0;
      expect(cfg.enemyContactDamage, 25.0);
      cfg.resetToDefaults();
    });
  });
}
