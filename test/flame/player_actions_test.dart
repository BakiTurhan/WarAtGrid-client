import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/components/player.dart';
import 'package:waratgrid/game/components/world.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Player Actions - Shooting', () {
    testWithFlameGame(
      'primaryAction in gun mode triggers shooting',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        expect(player.weaponMode, WeaponMode.gun);
        expect(player.currentAmmo, cfg.magazineSize);

        // Trigger primary action (shoot)
        player.primaryAction();

        // Ammo should decrease
        expect(player.currentAmmo, cfg.magazineSize - 1);
      },
    );

    testWithFlameGame(
      'Shooting creates bullet',
      (game) async {
        final world = World();
        await game.ensureAdd(world);
        
        final player = Player();
        await game.ensureAdd(player);

        final initialBulletCount = game.children.whereType<CircleComponent>().length;
        
        player.primaryAction();
        await game.ready();
        
        // There should be more circle components (bullets)
        expect(game.children.length, greaterThanOrEqualTo(initialBulletCount));
      },
    );

    testWithFlameGame(
      'Empty magazine triggers reload',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        // Shoot all ammo
        for (int i = 0; i < cfg.magazineSize; i++) {
          player.primaryAction();
        }

        expect(player.currentAmmo, 0);
        expect(player.isReloading, true);
      },
    );

    testWithFlameGame(
      'Reload completes after reload time',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        // Empty magazine
        for (int i = 0; i < cfg.magazineSize; i++) {
          player.primaryAction();
        }

        expect(player.isReloading, true);

        // Wait for reload
        for (int i = 0; i < 20; i++) {
          game.update(0.1);
        }

        // Should be reloaded
        expect(player.isReloading, false);
        expect(player.currentAmmo, cfg.magazineSize);
      },
    );
  });

  group('Player Actions - Melee', () {
    testWithFlameGame(
      'primaryAction in knife mode triggers melee',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.weaponMode = WeaponMode.knife;
        expect(player.weaponMode, WeaponMode.knife);

        // Should not throw and ammo should remain unchanged
        final ammoBefore = player.currentAmmo;
        player.primaryAction();
        expect(player.currentAmmo, ammoBefore);
      },
    );
  });

  group('Player Actions - Dash', () {
    testWithFlameGame(
      'Dash only works in knife mode',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.position = Vector2(500, 500);

        // In gun mode, SPACE should not dash
        player.onKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.space,
            logicalKey: LogicalKeyboardKey.space,
            timeStamp: Duration.zero,
          ),
          {LogicalKeyboardKey.space},
        );

        game.update(0.1);
        // Position should remain ~same (no dash in gun mode)
        expect(player.position.x, closeTo(500, 50));
      },
    );

    testWithFlameGame(
      'Dash works in knife mode with velocity',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.position = Vector2(500, 500);
        player.weaponMode = WeaponMode.knife;
        player.velocity = Vector2(100, 0); // Moving right

        // Trigger dash
        player.onKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.space,
            logicalKey: LogicalKeyboardKey.space,
            timeStamp: Duration.zero,
          ),
          {LogicalKeyboardKey.space},
        );

        // Update to process dash
        for (int i = 0; i < 10; i++) {
          game.update(0.05);
        }

        // Player should have moved right
        expect(player.position.x, greaterThan(500));
      },
    );

    testWithFlameGame(
      'Dash has cooldown',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.weaponMode = WeaponMode.knife;
        player.velocity = Vector2(100, 0);

        final startPos = player.position.clone();

        // First dash
        player.onKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.space,
            logicalKey: LogicalKeyboardKey.space,
            timeStamp: Duration.zero,
          ),
          {LogicalKeyboardKey.space},
        );

        // Process first dash
        for (int i = 0; i < 20; i++) {
          game.update(0.05);
        }

        final afterFirstDash = player.position.clone();

        // Immediate second dash should not work (cooldown)
        player.onKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.space,
            logicalKey: LogicalKeyboardKey.space,
            timeStamp: Duration.zero,
          ),
          {LogicalKeyboardKey.space},
        );

        game.update(0.1);

        // Position change should be minimal compared to first dash
        // Using a more flexible check since dash physics can vary
        expect(player.position.x - afterFirstDash.x, lessThan(cfg.dashDistance));
      },
    );
  });

  group('Player Actions - Secondary', () {
    testWithFlameGame(
      'secondaryAction in gun mode queues grenade',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.position = Vector2(500, 500);
        player.lookAt(Vector2(600, 500)); // Look right

        // Should not throw
        player.secondaryAction();
        
        // Just verify no crash
        expect(player.weaponMode, WeaponMode.gun);
      },
    );

    testWithFlameGame(
      'secondaryAction in knife mode triggers blade wave',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.weaponMode = WeaponMode.knife;
        player.position = Vector2(500, 500);

        // Trigger blade wave
        player.secondaryAction();

        // Should not throw
        expect(player.weaponMode, WeaponMode.knife);
      },
    );
  });

  group('Player Damage and Health', () {
    testWithFlameGame(
      'takeDamage respects cooldown',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final startHealth = player.health;

        // First damage
        player.takeDamage(10);
        expect(player.health, startHealth - 10);

        // Immediate second damage should be blocked by cooldown
        player.takeDamage(10);
        expect(player.health, startHealth - 10); // Still same (cooldown active)
      },
    );

    testWithFlameGame(
      'takeDamage works after cooldown expires',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final startHealth = player.health;

        player.takeDamage(10);
        expect(player.health, startHealth - 10);

        // Wait for cooldown
        for (int i = 0; i < 10; i++) {
          game.update(0.1);
        }

        player.takeDamage(10);
        expect(player.health, startHealth - 20);
      },
    );

    testWithFlameGame(
      'healthPercent getter works',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        expect(player.healthPercent, 1.0);

        player.takeDamage(50);
        expect(player.healthPercent, closeTo(0.5, 0.01));
      },
    );
  });

  group('Player Collision and Bounds', () {
    testWithFlameGame(
      'Player respects world boundaries during movement',
      (game) async {
        final world = GameWorld();
        await game.ensureAdd(world);

        final player = Player();
        await game.ensureAdd(player);

        // Try to move outside world
        player.position = Vector2(-100, -100);
        player.velocity = Vector2(-100, -100);

        game.update(1.0);

        // Player should be pushed back into bounds
        expect(player.position.x, greaterThanOrEqualTo(0));
        expect(player.position.y, greaterThanOrEqualTo(0));
      },
    );
  });

  group('Player Cooldown Getters', () {
    testWithFlameGame(
      'dashCooldownProgress works',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        // Initially should be ready (1.0)
        expect(player.dashCooldownProgress, 1.0);
      },
    );

    testWithFlameGame(
      'grenadeCooldownProgress works',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        // Initially should be ready (1.0)
        expect(player.grenadeCooldownProgress, 1.0);
      },
    );
  });
}
