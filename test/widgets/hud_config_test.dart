import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/config.dart';

// Note: HudOverlay requires a WarAtGridGame instance which is complex to mock.
// These tests cover the config values that HUD uses.

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('HUD Config Tests', () {
    test('Magazine size for ammo display', () {
      expect(cfg.magazineSize, 12);
    });

    test('Dash cooldown for progress bar', () {
      expect(cfg.dashCooldown, 1.5);
    });

    test('Grenade cooldown for progress bar', () {
      expect(cfg.grenadeCooldown, 10.0);
    });

    test('Player max health for health bar', () {
      expect(cfg.playerMaxHealth, 100.0);
    });

    test('Score digits for display', () {
      expect(cfg.scoreDigits, 6);
    });

    test('Reload time for ammo display', () {
      expect(cfg.reloadTime, 1.5);
    });
  });

  group('HUD Related Player Values', () {
    test('Dash kill score', () {
      expect(cfg.dashKillScore, 100);
    });

    test('Bullet kill score', () {
      expect(cfg.bulletKillScore, 50);
    });

    test('Melee kill score', () {
      expect(cfg.meleeKillScore, 50);
    });

    test('Grenade kill score', () {
      expect(cfg.grenadeKillScore, 75);
    });
  });
}
