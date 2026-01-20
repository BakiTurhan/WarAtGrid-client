import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'components/player.dart';
import 'components/enemy.dart';
import 'components/world.dart';
import 'components/fog_of_war.dart';
import '../config.dart';
import '../network/network_manager.dart';

class WarAtGridGame extends FlameGame with HasKeyboardHandlerComponents, MouseMovementDetector, TapDetector, SecondaryTapDetector, PanDetector {
  final VoidCallback? onPauseToggle;
  final NetworkManager? networkManager;
  
  WarAtGridGame({this.onPauseToggle, this.networkManager});
  
  bool get isOnlineMode => networkManager != null;

  final Player player = Player();
  late GameWorld gameWorld;
  late FogOfWar fogOfWar;
  double _enemySpawnTimer = 0;
  final Random _random = Random();

  late World flameWorld;
  late CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    flameWorld = World();
    add(flameWorld);

    cameraComponent = CameraComponent(world: flameWorld);
    cameraComponent.viewfinder.anchor = Anchor.center;
    add(cameraComponent);

    gameWorld = GameWorld();
    flameWorld.add(gameWorld);

    player.position = Vector2(cfg.worldWidth / 2, cfg.worldHeight / 2);
    flameWorld.add(player);

    cameraComponent.follow(player);
    
    fogOfWar = FogOfWar(player: player);
    flameWorld.add(fogOfWar);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _enemySpawnTimer += dt;
    if (_enemySpawnTimer > cfg.enemySpawnInterval) {
      final edge = _random.nextInt(4);
      double x, y;
      switch (edge) {
        case 0:
          x = 50 + _random.nextDouble() * (cfg.worldWidth - 100);
          y = 50;
          break;
        case 1:
          x = 50 + _random.nextDouble() * (cfg.worldWidth - 100);
          y = cfg.worldHeight - 50;
          break;
        case 2:
          x = 50;
          y = 50 + _random.nextDouble() * (cfg.worldHeight - 100);
          break;
        default:
          x = cfg.worldWidth - 50;
          y = 50 + _random.nextDouble() * (cfg.worldHeight - 100);
      }
      flameWorld.add(Enemy(player: player, position: Vector2(x, y)));
      _enemySpawnTimer = 0;
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final worldPos = cameraComponent.viewfinder.globalToLocal(info.eventPosition.global);
    player.lookAt(worldPos);
  }

  // Continuous look while dragging (holding mouse button)
  @override
  void onPanUpdate(DragUpdateInfo info) {
    final worldPos = cameraComponent.viewfinder.globalToLocal(info.eventPosition.global);
    player.lookAt(worldPos);
  }

  @override
  void onTapDown(TapDownInfo info) {
    final worldPos = cameraComponent.viewfinder.globalToLocal(info.eventPosition.global);
    player.lookAt(worldPos);
    player.primaryAction();
  }

  @override
  void onSecondaryTapDown(TapDownInfo info) {
    final worldPos = cameraComponent.viewfinder.globalToLocal(info.eventPosition.global);
    player.lookAt(worldPos);
    player.secondaryAction();
  }

  @override
  Color backgroundColor() => const Color(0xFF111111);
}


