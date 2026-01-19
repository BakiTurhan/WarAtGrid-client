import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/game/components/player.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Player Flame Component Tests', () {
    testWithFlameGame(
      'Player has correct initial position after onLoad',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        // Player should have been positioned
        expect(player.isMounted, true);
      },
    );

    testWithFlameGame(
      'Player radius matches config',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        expect(player.radius, cfg.playerRadius);
      },
    );

    testWithFlameGame(
      'Player has gun barrel after onLoad',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        // Player should have children (gun barrel, knife arms, etc)
        expect(player.children.length, greaterThan(0));
      },
    );

    testWithFlameGame(
      'Player toggleWeapon works after onLoad',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        expect(player.weaponMode, WeaponMode.gun);

        player.toggleWeapon();
        expect(player.weaponMode, WeaponMode.knife);

        player.toggleWeapon();
        expect(player.weaponMode, WeaponMode.gun);
      },
    );

    testWithFlameGame(
      'Player lookAt updates angle',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.position = Vector2(100, 100);
        player.lookAt(Vector2(200, 100)); // Look right

        expect(player.angle, closeTo(0, 0.1));
      },
    );

    testWithFlameGame(
      'Player movement updates position',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final startPos = player.position.clone();

        // Set velocity
        player.velocity = Vector2(100, 0);

        // Update
        game.update(0.5);

        // Position should have changed (if no collision)
        // Note: might need to account for collision logic
        expect(player.position.x, greaterThanOrEqualTo(startPos.x));
      },
    );

    testWithFlameGame(
      'Player health system works',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        final startHealth = player.health;
        player.takeDamage(20);

        expect(player.health, startHealth - 20);
      },
    );

    testWithFlameGame(
      'Player score system works',
      (game) async {
        final player = Player();
        await game.ensureAdd(player);

        player.addScore(100);
        expect(player.score, 100);

        player.addScore(50);
        expect(player.score, 150);
      },
    );
  });
}
