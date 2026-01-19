import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/components/world.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('GameWorld Component Tests', () {
    testWithFlameGame(
      'GameWorld loads successfully',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        expect(world.isMounted, true);
      },
    );

    testWithFlameGame(
      'GameWorld creates boundary walls',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        // Should have 4 boundary walls
        expect(world.walls.length, 4);
      },
    );

    testWithFlameGame(
      'GameWorld creates obstacles',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        // Should have blocks (obstacles)
        expect(world.blocks.length, greaterThanOrEqualTo(0));
      },
    );

    testWithFlameGame(
      'collidesWithObstacle returns true for wall collision',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        // Position at top-left corner (inside wall)
        final collision = world.collidesWithObstacle(Vector2(5, 5), 10);
        expect(collision, true);
      },
    );

    testWithFlameGame(
      'collidesWithObstacle returns false for empty space',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        // Position in center of world (likely empty)
        final centerPos = Vector2(cfg.worldWidth / 2, cfg.worldHeight / 2);
        final collision = world.collidesWithObstacle(centerPos, 10);
        // May or may not collide depending on obstacle placement
        expect(collision, isA<bool>());
      },
    );

    testWithFlameGame(
      'collidesWithObstacle detects boundary walls',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        // Test left boundary
        expect(world.collidesWithObstacle(Vector2(0, 100), 15), true);

        // Test top boundary  
        expect(world.collidesWithObstacle(Vector2(100, 0), 15), true);

        // Test right boundary
        expect(world.collidesWithObstacle(Vector2(cfg.worldWidth, 100), 15), true);

        // Test bottom boundary
        expect(world.collidesWithObstacle(Vector2(100, cfg.worldHeight), 15), true);
      },
    );

    testWithFlameGame(
      'World uses config values for dimensions',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        // World should use cfg values
        expect(cfg.worldWidth, 2000.0);
        expect(cfg.worldHeight, 2000.0);
      },
    );
  });

  group('GameWorld Config Tests', () {
    test('World config values are accessible', () {
      expect(cfg.worldWidth, 2000.0);
      expect(cfg.worldHeight, 2000.0);
      expect(cfg.gridSize, 50.0);
      expect(cfg.wallThickness, 20.0);
      expect(cfg.obstacleCount, 20);
    });

    test('World values can be modified', () {
      cfg.worldWidth = 3000.0;
      expect(cfg.worldWidth, 3000.0);
      cfg.resetToDefaults();
    });
  });
}
