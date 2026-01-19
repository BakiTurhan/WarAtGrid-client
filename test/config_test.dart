import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/config.dart';

void main() {
  group('GameConfig Tests', () {
    setUp(() {
      // Reset to defaults before each test
      cfg.resetToDefaults();
    });

    test('Singleton returns same instance', () {
      final instance1 = GameConfig.instance;
      final instance2 = GameConfig.instance;
      expect(identical(instance1, instance2), true);
    });

    test('cfg shorthand works', () {
      expect(cfg, equals(GameConfig.instance));
    });

    test('Default player values are correct', () {
      expect(cfg.playerRadius, 20.0);
      expect(cfg.playerSpeed, 200.0);
      expect(cfg.playerKnifeSpeedMultiplier, 1.5);
      expect(cfg.playerMaxHealth, 100.0);
    });

    test('Default dash values are correct', () {
      expect(cfg.dashDistance, 300.0);
      expect(cfg.dashSpeed, 1500.0);
      expect(cfg.dashCooldown, 1.5);
    });

    test('Default ammo values are correct', () {
      expect(cfg.magazineSize, 12);
      expect(cfg.reloadTime, 1.5);
    });

    test('Default grenade values are correct', () {
      expect(cfg.grenadeRadius, 80.0);
      expect(cfg.grenadeCooldown, 10.0);
    });

    test('Default blade wave values are correct', () {
      expect(cfg.bladeWaveRange, 200.0);
      expect(cfg.bladeWaveAngle, 0.8);
      expect(cfg.bladeWaveCooldown, 3.0);
    });

    test('Default enemy values are correct', () {
      expect(cfg.enemySpeed, 100.0);
      expect(cfg.enemyContactDamage, 10.0);
      expect(cfg.enemySpawnInterval, 2.0);
    });

    test('Values can be modified at runtime', () {
      cfg.playerSpeed = 500.0;
      expect(cfg.playerSpeed, 500.0);

      cfg.dashCooldown = 3.0;
      expect(cfg.dashCooldown, 3.0);

      cfg.magazineSize = 30;
      expect(cfg.magazineSize, 30);
    });

    test('resetToDefaults restores original values', () {
      // Modify some values
      cfg.playerSpeed = 999.0;
      cfg.dashDistance = 999.0;
      cfg.enemySpeed = 999.0;

      // Reset
      cfg.resetToDefaults();

      // Check they're back to defaults
      expect(cfg.playerSpeed, 200.0);
      expect(cfg.dashDistance, 300.0);
      expect(cfg.enemySpeed, 100.0);
    });

    test('Score values are correct', () {
      expect(cfg.bulletKillScore, 50);
      expect(cfg.dashKillScore, 100);
      expect(cfg.grenadeKillScore, 75);
      expect(cfg.meleeKillScore, 50);
    });

    test('World values are correct', () {
      expect(cfg.worldWidth, 2000.0);
      expect(cfg.worldHeight, 2000.0);
      expect(cfg.gridSize, 50.0);
      expect(cfg.obstacleCount, 20);
    });

    test('FOV values are correct', () {
      expect(cfg.viewRadius, 600.0);
    });
  });
}
