import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'bullet.dart';
import 'enemy.dart';
import 'world.dart';
import 'grenade.dart';
import '../../config.dart';
import '../war_at_grid_game.dart';

enum WeaponMode { gun, knife }

class Player extends CircleComponent with KeyboardHandler, HasGameRef<FlameGame> {
  static final _paint = Paint()..color = Colors.blue;
  Vector2 velocity = Vector2.zero();

  Player() : super(
    radius: cfg.playerRadius, 
    anchor: Anchor.center, 
    paint: _paint,
  );

  // Weapon State
  WeaponMode weaponMode = WeaponMode.gun;
  
  // Ammo System
  int _currentAmmo = 12;
  bool _isReloading = false;
  double _reloadTimer = 0;
  
  // Grenade
  double _grenadeCooldownTimer = 0;
  double _bladeWaveCooldownTimer = 0;
  
  // Dash State
  double _dashCooldownTimer = 0;
  bool _isDashing = false;
  Vector2 _dashTarget = Vector2.zero();
  Vector2 _dashDirection = Vector2.zero();
  
  // Health System
  double health = 100.0;
  double _damageCooldown = 0.0;
  
  // Score
  int score = 0;
  
  // Visual components
  late RectangleComponent _gunBarrel;
  late RectangleComponent _knifeArmLeft;
  late RectangleComponent _knifeArmRight;
  late CircleComponent _knifeRangeIndicator;
  
  // Getters
  bool get isAlive => health > 0;
  int get currentAmmo => _currentAmmo;
  bool get isReloading => _isReloading;
  double get reloadProgress => _isReloading ? (_reloadTimer / cfg.reloadTime).clamp(0.0, 1.0) : 1.0;
  double get dashCooldownProgress => cfg.dashCooldown > 0 
      ? (1 - (_dashCooldownTimer / cfg.dashCooldown)).clamp(0.0, 1.0) : 1.0;
  double get grenadeCooldownProgress => cfg.grenadeCooldown > 0
      ? (1 - (_grenadeCooldownTimer / cfg.grenadeCooldown)).clamp(0.0, 1.0) : 1.0;
  double get healthPercent => (health / cfg.playerMaxHealth).clamp(0.0, 1.0);
  
  void takeDamage(double amount) {
    if (_damageCooldown > 0) return;
    health -= amount;
    if (health < 0) health = 0;
    _damageCooldown = cfg.playerDamageCooldown;
  }
  
  void addScore(int points) { score += points; }

  // Mobile Input
  Vector2 _mobileInput = Vector2.zero();
  
  /// Set movement from mobile joystick (dx, dy are -1 to 1)
  void setMobileMovement(double dx, double dy) {
    _mobileInput = Vector2(dx, dy);
    velocity = _mobileInput * cfg.playerSpeed;
    
    // Update facing direction if moving
    if (!_mobileInput.isZero()) {
      angle = atan2(dy, dx);
    }
  }
  
  /// Toggle between gun and knife mode
  void toggleWeaponMode() {
    weaponMode = weaponMode == WeaponMode.gun ? WeaponMode.knife : WeaponMode.gun;
    _updateWeaponVisuals();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    health = cfg.playerStartHealth;
    _currentAmmo = cfg.magazineSize;
    
    _gunBarrel = RectangleComponent(
      position: Vector2(radius, radius),
      size: Vector2(radius, 10),
      anchor: Anchor.centerLeft,
      paint: Paint()..color = Colors.white,
    );
    add(_gunBarrel);
    
    final armPaint = Paint()..color = Colors.grey.shade400;
    _knifeArmLeft = RectangleComponent(
      position: Vector2(radius, radius - 15),
      size: Vector2(15, 6),
      anchor: Anchor.centerLeft,
      paint: armPaint,
    );
    _knifeArmRight = RectangleComponent(
      position: Vector2(radius, radius + 15),
      size: Vector2(15, 6),
      anchor: Anchor.centerLeft,
      paint: armPaint,
    );
    add(_knifeArmLeft);
    add(_knifeArmRight);
    
    _knifeRangeIndicator = CircleComponent(
      radius: cfg.dashDistance,
      anchor: Anchor.center,
      position: Vector2(radius, radius),
      paint: Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(_knifeRangeIndicator);
    
    _updateWeaponVisuals();
  }

  void _updateWeaponVisuals() {
    if (weaponMode == WeaponMode.gun) {
      _gunBarrel.paint.color = Colors.white;
      _knifeArmLeft.paint.color = Colors.transparent;
      _knifeArmRight.paint.color = Colors.transparent;
      _knifeRangeIndicator.paint.color = Colors.transparent;
    } else {
      _gunBarrel.paint.color = Colors.transparent;
      _knifeArmLeft.paint.color = Colors.grey.shade400;
      _knifeArmRight.paint.color = Colors.grey.shade400;
      _knifeRangeIndicator.paint.color = Colors.cyan.withOpacity(0.2);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Auto-reload timer
    if (_isReloading) {
      _reloadTimer += dt;
      if (_reloadTimer >= cfg.reloadTime) {
        _currentAmmo = cfg.magazineSize;
        _isReloading = false;
        _reloadTimer = 0;
      }
    }

    if (_grenadeCooldownTimer > 0) _grenadeCooldownTimer -= dt;
    if (_bladeWaveCooldownTimer > 0) _bladeWaveCooldownTimer -= dt;
    if (_dashCooldownTimer > 0) _dashCooldownTimer -= dt;
    if (_damageCooldown > 0) _damageCooldown -= dt;

    if (_isDashing) {
      final travel = _dashDirection * cfg.dashSpeed * dt;
      final remaining = _dashTarget - position;
      
      if (remaining.length <= travel.length) {
        position = _dashTarget.clone();
        _endDash();
      } else {
        final newPos = position + travel;
        final gameWorld = parent?.children.whereType<GameWorld>().firstOrNull;
        if (gameWorld != null && gameWorld.collidesWithObstacle(newPos, radius)) {
          _endDash();
        } else {
          position = newPos;
          _checkDashCollision();
        }
      }
    } else {
      if (!velocity.isZero()) {
        final gameWorld = parent?.children.whereType<GameWorld>().firstOrNull;
        final moveX = Vector2(velocity.x * dt, 0);
        final moveY = Vector2(0, velocity.y * dt);
        
        final newPos = position + velocity * dt;
        if (gameWorld == null || !gameWorld.collidesWithObstacle(newPos, radius)) {
          position = newPos;
        } else {
          final newPosX = position + moveX;
          if (gameWorld == null || !gameWorld.collidesWithObstacle(newPosX, radius)) {
            position = newPosX;
          }
          final newPosY = position + moveY;
          if (gameWorld == null || !gameWorld.collidesWithObstacle(newPosY, radius)) {
            position = newPosY;
          }
        }
      }
    }
    
    position.x = position.x.clamp(cfg.wallThickness + radius, cfg.worldWidth - cfg.wallThickness - radius);
    position.y = position.y.clamp(cfg.wallThickness + radius, cfg.worldHeight - cfg.wallThickness - radius);
    
    if (_dashCooldownTimer > 0) _dashCooldownTimer -= dt;
    if (_damageCooldown > 0) _damageCooldown -= dt;
    if (_grenadeCooldownTimer > 0) _grenadeCooldownTimer -= dt;
  }

  void _checkDashCollision() {
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    for (final enemy in enemies) {
      if (enemy.position.distanceTo(position) < radius + enemy.radius + 10) {
        enemy.removeFromParent();
        addScore(cfg.dashKillScore);
        _endDash();
        return;
      }
    }
  }

  void _endDash() {
    _isDashing = false;
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    for (final enemy in enemies) {
      if (enemy.position.distanceTo(position) < cfg.dashAoeRadius + enemy.radius) {
        enemy.removeFromParent();
        addScore(cfg.dashKillScore);
      }
    }
    
    final effect = CircleComponent(
      radius: cfg.dashAoeRadius,
      paint: Paint()..color = Colors.red.withOpacity(0.4),
      anchor: Anchor.center,
      position: position.clone(),
    );
    parent?.add(effect);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (effect.isMounted) effect.removeFromParent();
    });
  }

  void lookAt(Vector2 targetPosition) {
    final direction = targetPosition - position;
    angle = atan2(direction.y, direction.x);
  }

  void primaryAction() {
    if (weaponMode == WeaponMode.gun) {
      _shoot();
    } else {
      _meleeAttack();
    }
  }

  void secondaryAction() {
    if (weaponMode == WeaponMode.gun) {
      _throwGrenade();
    } else {
      _bladeRush();
    }
  }

  void _bladeRush() {
    if (_bladeWaveCooldownTimer > 0) return;
    
    // Create wave effect that kills enemies as it expands
    final wave = _BladeWaveEffect(
      origin: position.clone(),
      playerAngle: angle,
      range: cfg.bladeWaveRange,
      arcAngle: cfg.bladeWaveAngle,
      player: this,
    );
    parent?.add(wave);
    
    _bladeWaveCooldownTimer = cfg.bladeWaveCooldown;
  }

  void _throwGrenade() {
    if (_grenadeCooldownTimer > 0) return;
    final direction = Vector2(cos(angle), sin(angle));
    final grenadePos = position + (direction * 25);
    parent?.add(Grenade(position: grenadePos, direction: direction, thrower: this));
    _grenadeCooldownTimer = cfg.grenadeCooldown;
  }

  void _meleeAttack() {
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    final attackRange = radius + 40;
    
    for (final enemy in enemies) {
      final dist = enemy.position.distanceTo(position);
      if (dist < attackRange) {
        final toEnemy = enemy.position - position;
        final enemyAngle = atan2(toEnemy.y, toEnemy.x);
        final angleDiff = (enemyAngle - angle).abs();
        if (angleDiff < 0.52 || angleDiff > 5.76) {
          enemy.removeFromParent();
          addScore(cfg.meleeKillScore);
        }
      }
    }
    
    final swingEffect = RectangleComponent(
      position: Vector2(radius + 10, radius),
      size: Vector2(30, 40),
      anchor: Anchor.centerLeft,
      paint: Paint()..color = Colors.white.withOpacity(0.5),
    );
    add(swingEffect);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (swingEffect.isMounted) swingEffect.removeFromParent();
    });
  }

  void _shoot() {
    if (_isReloading) return;
    if (_currentAmmo <= 0) {
      _startReload();
      return;
    }
    
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    for (final enemy in enemies) {
      if (enemy.position.distanceTo(position) < radius + enemy.radius + 5) {
        enemy.removeFromParent();
        addScore(cfg.meleeKillScore);
      }
    }
    
    final direction = Vector2(cos(angle), sin(angle));
    final bulletPos = position + (direction * 30);
    parent?.add(Bullet(position: bulletPos, direction: direction));
    
    _currentAmmo--;
    if (_currentAmmo <= 0) _startReload();
  }

  void _startReload() {
    if (_isReloading) return;
    _isReloading = true;
    _reloadTimer = 0;
  }

  void dash() {
    if (_dashCooldownTimer > 0 || _isDashing) return;
    if (!velocity.isZero()) {
      _dashDirection = velocity.normalized();
    } else {
      _dashDirection = Vector2(cos(angle), sin(angle));
    }
    _dashTarget = position + (_dashDirection * cfg.dashDistance);
    _isDashing = true;
    _dashCooldownTimer = cfg.dashCooldown;
  }

  void toggleWeapon() {
    weaponMode = weaponMode == WeaponMode.gun ? WeaponMode.knife : WeaponMode.gun;
    _updateWeaponVisuals();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // ESC = Pause Game
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (gameRef is WarAtGridGame) {
        (gameRef as WarAtGridGame).onPauseToggle?.call();
        return true;
      }
    }

    // Q = Weapon switch
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyQ) {
      toggleWeapon();
    }
    
    // SPACE = Dash (only knife mode)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      if (weaponMode == WeaponMode.knife) {
        dash();
      }
    }
    
    // Movement
    double x = 0, y = 0;
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) y += 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) x += 1;
    
    velocity = Vector2(x, y);
    if (!velocity.isZero()) {
      velocity.normalize();
      final speed = weaponMode == WeaponMode.knife 
          ? cfg.playerSpeed * cfg.playerKnifeSpeedMultiplier : cfg.playerSpeed;
      velocity.scale(speed);
    }
    
    return true;
  }
}

/// Visual effect for blade wave - kills enemies as it expands
class _BladeWaveEffect extends PositionComponent with HasGameRef {
  final Vector2 origin;
  final double playerAngle;
  final double range;
  final double arcAngle;
  final Player player;
  double _timer = 0;
  final Set<int> _killedEnemies = {};
  
  _BladeWaveEffect({
    required this.origin,
    required this.playerAngle,
    required this.range,
    required this.arcAngle,
    required this.player,
  }) : super(position: origin, angle: playerAngle);

  @override
  void update(double dt) {
    super.update(dt);
    
    final duration = 0.5;
    final prevProgress = (_timer / duration).clamp(0.0, 1.0);
    final prevRadius = 20.0 + (range * prevProgress);
    
    _timer += dt;
    
    final progress = (_timer / duration).clamp(0.0, 1.0);
    final currentRadius = 20.0 + (range * progress);
    
    // Kill enemies that the wave just reached (between prev and current radius)
    final enemies = parent?.children.whereType<Enemy>().toList() ?? [];
    for (final enemy in enemies) {
      if (_killedEnemies.contains(enemy.hashCode)) continue;
      
      final dist = enemy.position.distanceTo(origin);
      // Check if wave just passed this enemy
      if (dist >= prevRadius && dist <= currentRadius) {
        final toEnemy = enemy.position - origin;
        final enemyAngle = atan2(toEnemy.y, toEnemy.x);
        var angleDiff = (enemyAngle - playerAngle).abs();
        if (angleDiff > pi) angleDiff = 2 * pi - angleDiff;
        
        if (angleDiff < arcAngle) {
          _killedEnemies.add(enemy.hashCode);
          enemy.removeFromParent();
          player.addScore(cfg.meleeKillScore);
        }
      }
    }
    
    if (_timer > duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final duration = 0.5;
    final progress = (_timer / duration).clamp(0.0, 1.0);
    final opacity = (1 - progress * 0.8).clamp(0.0, 1.0);
    final currentRadius = 20.0 + (range * progress);
    final arcThickness = 8.0;
    
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcThickness
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: currentRadius),
      -arcAngle,
      arcAngle * 2,
      false,
      paint,
    );
    
    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: currentRadius + arcThickness / 2),
      -arcAngle,
      arcAngle * 2,
      false,
      edgePaint,
    );
  }
}
