import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:waratgrid/game/components/player.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Player Initialization', () {
    test('Creates with correct radius from config', () {
      final player = Player();
      expect(player.radius, cfg.playerRadius);
    });

    test('Starts with gun mode', () {
      final player = Player();
      expect(player.weaponMode, WeaponMode.gun);
    });

    test('Starts alive with full health', () {
      final player = Player();
      expect(player.isAlive, true);
      expect(player.health, cfg.playerStartHealth);
    });

    test('Starts with full ammo', () {
      final player = Player();
      expect(player.currentAmmo, cfg.magazineSize);
      expect(player.isReloading, false);
    });

    test('Starts with zero score', () {
      final player = Player();
      expect(player.score, 0);
    });
  });

  group('Player Movement', () {
    test('Initial velocity is zero', () {
      final player = Player();
      expect(player.velocity, Vector2.zero());
    });

    test('WASD keys set velocity', () {
      final player = Player();

      // W key - move up (negative Y)
      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyW,
          logicalKey: LogicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyW},
      );
      expect(player.velocity.y, lessThan(0));

      // S key - move down (positive Y)
      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyS,
          logicalKey: LogicalKeyboardKey.keyS,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyS},
      );
      expect(player.velocity.y, greaterThan(0));

      // A key - move left (negative X)
      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyA,
          logicalKey: LogicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyA},
      );
      expect(player.velocity.x, lessThan(0));

      // D key - move right (positive X)
      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyD,
          logicalKey: LogicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyD},
      );
      expect(player.velocity.x, greaterThan(0));
    });

    test('Arrow keys set velocity', () {
      final player = Player();

      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.arrowUp},
      );
      expect(player.velocity.y, lessThan(0));

      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.arrowDown},
      );
      expect(player.velocity.y, greaterThan(0));
    });

    test('Releasing keys stops movement', () {
      final player = Player();

      // Press and release
      player.onKeyEvent(
        const KeyUpEvent(
          physicalKey: PhysicalKeyboardKey.keyW,
          logicalKey: LogicalKeyboardKey.keyW,
          timeStamp: Duration.zero,
        ),
        {},
      );
      expect(player.velocity, Vector2.zero());
    });

    test('Diagonal movement (W+D)', () {
      final player = Player();

      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyD,
          logicalKey: LogicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyD},
      );

      expect(player.velocity.x, greaterThan(0));
      expect(player.velocity.y, lessThan(0));
    });

    test('Velocity is normalized for diagonal', () {
      final player = Player();

      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyD,
          logicalKey: LogicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyD},
      );

      // Velocity length should equal player speed (normalized * speed)
      expect(player.velocity.length, closeTo(cfg.playerSpeed, 0.1));
    });

    test('Knife mode increases speed', () {
      final player = Player();
      player.weaponMode = WeaponMode.knife;

      player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyD,
          logicalKey: LogicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyD},
      );

      final expectedSpeed = cfg.playerSpeed * cfg.playerKnifeSpeedMultiplier;
      expect(player.velocity.length, closeTo(expectedSpeed, 0.1));
    });
  });

  group('Weapon Mode', () {
    test('Can change weapon mode directly', () {
      final player = Player();
      expect(player.weaponMode, WeaponMode.gun);

      player.weaponMode = WeaponMode.knife;
      expect(player.weaponMode, WeaponMode.knife);

      player.weaponMode = WeaponMode.gun;
      expect(player.weaponMode, WeaponMode.gun);
    });
  });

  group('Score System', () {
    test('addScore increases score', () {
      final player = Player();
      expect(player.score, 0);

      player.addScore(100);
      expect(player.score, 100);

      player.addScore(50);
      expect(player.score, 150);
    });

    test('addScore handles negative values', () {
      final player = Player();
      player.addScore(100);
      player.addScore(-50);
      expect(player.score, 50);
    });
  });

  group('Health System', () {
    test('takeDamage reduces health', () {
      final player = Player();
      final initialHealth = player.health;

      player.takeDamage(25);
      expect(player.health, initialHealth - 25);
    });

    test('Player dies when health reaches zero', () {
      final player = Player();
      expect(player.isAlive, true);

      player.takeDamage(cfg.playerMaxHealth);
      expect(player.isAlive, false);
    });

    test('Health cannot go below zero', () {
      final player = Player();
      player.takeDamage(500); // More than max health

      expect(player.health, lessThanOrEqualTo(0));
    });
  });

  group('LookAt', () {
    test('lookAt updates player angle', () {
      final player = Player();
      player.position = Vector2(100, 100);

      // Look to the right
      player.lookAt(Vector2(200, 100));
      expect(player.angle, closeTo(0, 0.01)); // 0 radians = right

      // Look down
      player.lookAt(Vector2(100, 200));
      expect(player.angle, closeTo(1.57, 0.1)); // ~pi/2 radians = down
    });
  });
}
