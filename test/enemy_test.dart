import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('Enemy Config Tests', () {
    test('Default enemy radius is correct', () {
      expect(cfg.enemyRadius, 15.0);
    });

    test('Default enemy speed is correct', () {
      expect(cfg.enemySpeed, 100.0);
    });

    test('Default enemy contact damage is correct', () {
      expect(cfg.enemyContactDamage, 10.0);
    });

    test('Default enemy spawn interval is correct', () {
      expect(cfg.enemySpawnInterval, 2.0);
    });

    test('Enemy speed can be modified', () {
      cfg.enemySpeed = 200.0;
      expect(cfg.enemySpeed, 200.0);
    });

    test('Enemy damage can be modified', () {
      cfg.enemyContactDamage = 25.0;
      expect(cfg.enemyContactDamage, 25.0);
    });

    test('Enemy spawn rate can be modified', () {
      cfg.enemySpawnInterval = 0.5;
      expect(cfg.enemySpawnInterval, 0.5);
    });

    test('Reset restores enemy values', () {
      cfg.enemySpeed = 999.0;
      cfg.enemyContactDamage = 999.0;
      cfg.resetToDefaults();

      expect(cfg.enemySpeed, 100.0);
      expect(cfg.enemyContactDamage, 10.0);
    });
  });
}
