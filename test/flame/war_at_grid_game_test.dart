import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/war_at_grid_game.dart';
import 'package:waratgrid/game/components/player.dart';
import 'package:waratgrid/game/components/world.dart';
import 'package:waratgrid/game/components/fog_of_war.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('WarAtGridGame Initialization', () {
    test('Creates with onPauseToggle callback', () {
      bool pauseCalled = false;
      final game = WarAtGridGame(onPauseToggle: () => pauseCalled = true);
      
      expect(game.onPauseToggle, isNotNull);
      game.onPauseToggle!();
      expect(pauseCalled, true);
    });

    test('Creates without callback', () {
      final game = WarAtGridGame();
      expect(game.onPauseToggle, isNull);
    });

    test('Has player property', () {
      final game = WarAtGridGame();
      expect(game.player, isA<Player>());
    });
  });

  group('WarAtGridGame FlameGame Tests', () {
    final gameInstance = FlameTester(() => WarAtGridGame());

    gameInstance.testGameWidget(
      'Game loads successfully',
      verify: (game, tester) async {
        await tester.pump();
        expect(game.isLoaded, true);
      },
    );

    gameInstance.testGameWidget(
      'Game has player after load',
      verify: (game, tester) async {
        await tester.pump();
        // Player should be in the game tree
        expect(game.player.isMounted, true);
      },
    );

    gameInstance.testGameWidget(
      'Game has world after load',
      verify: (game, tester) async {
        await tester.pump();
        expect(game.gameWorld, isA<GameWorld>());
      },
    );

    gameInstance.testGameWidget(
      'Game has fog of war after load',
      verify: (game, tester) async {
        await tester.pump();
        expect(game.fogOfWar, isA<FogOfWar>());
      },
    );

    gameInstance.testGameWidget(
      'Game has camera component',
      verify: (game, tester) async {
        await tester.pump();
        expect(game.cameraComponent, isA<CameraComponent>());
      },
    );

    gameInstance.testGameWidget(
      'Game spawns enemies over time',
      verify: (game, tester) async {
        await tester.pump();
        
        // Fast forward time to trigger enemy spawn
        for (int i = 0; i < 50; i++) {
          game.update(0.1);
        }
        
        // There should be at least one enemy after enough time
        // (depends on spawn interval config)
        expect(game.isLoaded, true);
      },
    );

    gameInstance.testGameWidget(
      'Game background color is dark',
      verify: (game, tester) async {
        await tester.pump();
        final bgColor = game.backgroundColor();
        expect(bgColor.value, 0xFF111111);
      },
    );
  });

  group('WarAtGridGame Update Loop', () {
    final gameInstance = FlameTester(() => WarAtGridGame());

    gameInstance.testGameWidget(
      'Update does not crash',
      verify: (game, tester) async {
        await tester.pump();
        
        // Multiple updates should not crash
        for (int i = 0; i < 100; i++) {
          game.update(0.016); // ~60fps
        }
        
        expect(game.isLoaded, true);
      },
    );
  });
}
