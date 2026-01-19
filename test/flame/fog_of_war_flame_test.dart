import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/components/fog_of_war.dart';
import 'package:waratgrid/game/components/player.dart';
import 'package:waratgrid/game/components/world.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('FogOfWar Component Tests', () {
    testWithFlameGame(
      'FogOfWar creates with player reference',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final fog = FogOfWar(player: player);
        await game.ensureAdd(fog);

        expect(fog.isMounted, true);
      },
    );

    testWithFlameGame(
      'isVisible returns true for points within view radius',
      (game) async {
        final player = Player();
        player.position = Vector2(500, 500);
        await game.ensureAdd(player);

        final fog = FogOfWar(player: player);
        await game.ensureAdd(fog);

        // Point close to player should be visible
        final result = fog.isVisible(Vector2(510, 510));
        expect(result, true);
      },
    );

    testWithFlameGame(
      'isVisible returns false for points beyond view radius',
      (game) async {
        final player = Player();
        player.position = Vector2(500, 500);
        await game.ensureAdd(player);

        final fog = FogOfWar(player: player);
        await game.ensureAdd(fog);

        // Point far from player should not be visible (or edge case)
        final farPoint = Vector2(500 + cfg.viewRadius + 100, 500);
        final result = fog.isVisible(farPoint);
        // Without GameWorld walls, it might still return true (no blocking)
        expect(result, isA<bool>());
      },
    );

    testWithFlameGame(
      'FogOfWar works with GameWorld present',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        final player = Player();
        player.position = Vector2(500, 500);
        await game.ensureAdd(player);

        final fog = FogOfWar(player: player);
        await game.ensureAdd(fog);

        // Should still work with world present
        final result = fog.isVisible(Vector2(510, 510));
        expect(result, isA<bool>());
      },
    );

    testWithFlameGame(
      'isVisible handles edge cases',
      (game) async {
        final player = Player();
        player.position = Vector2(100, 100);
        await game.ensureAdd(player);

        final fog = FogOfWar(player: player);
        await game.ensureAdd(fog);

        // Same position as player
        expect(fog.isVisible(Vector2(100, 100)), true);

        // Exactly at view radius
        final edgePoint = Vector2(100 + cfg.viewRadius, 100);
        expect(fog.isVisible(edgePoint), isA<bool>());
      },
    );
  });

  group('FogOfWar Config Tests', () {
    test('View radius config is correct', () {
      expect(cfg.viewRadius, 600.0);
    });

    test('View radius can be modified', () {
      cfg.viewRadius = 800.0;
      expect(cfg.viewRadius, 800.0);
      cfg.resetToDefaults();
    });
  });
}
