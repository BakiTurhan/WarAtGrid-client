import 'dart:async';
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
import 'components/remote_player.dart';
import 'components/remote_bullet.dart';
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
  
  // Remote player management
  final Map<String, RemotePlayer> _remotePlayers = {};
  final Map<String, RemoteBullet> _remoteBullets = {};
  StreamSubscription? _stateSubscription;
  String? _localPlayerId;
  
  // Input state tracking
  double _lastSentDx = 0;
  double _lastSentDy = 0;
  double _lastSentRotation = 0;

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

    player.position = Vector2(100, 100);  // Match server start position
    flameWorld.add(player);

    cameraComponent.follow(player);
    
    fogOfWar = FogOfWar(player: player);
    flameWorld.add(fogOfWar);
    
    // Subscribe to network state updates
    if (isOnlineMode) {
      _subscribeToNetworkState();
      
      // Hook player shooting to send action to server
      player.onShoot = () {
        print("NET_DEBUG: Sending SHOOT action");
        networkManager!.sendInput(
          dx: 0,
          dy: 0,
          rotation: player.angle,
          actions: ['shoot'],
        );
      };
    }
  }
  
  void _subscribeToNetworkState() {
    // Check if we already received the ID (handled race condition)
    if (networkManager!.localPlayerId != null) {
      _localPlayerId = networkManager!.localPlayerId;
      print("NET_DEBUG: Recovered Local ID from NetworkManager: $_localPlayerId");
    }
    
    _stateSubscription = networkManager!.stateStream.listen((message) {
      final type = message['type'] as String?;
      
      // Handle welcome message (sets our player ID)
      if (type == 'welcome') {
        final payload = message['payload'] as Map<String, dynamic>;
        final newId = payload['id'] as String;
        print("NET_DEBUG: Welcome received. My ID: $newId");
        
        _localPlayerId = newId;
        final x = (payload['x'] as num).toDouble();
        final y = (payload['y'] as num).toDouble();
        player.position = Vector2(x, y);
        return;
      }
      
      // Handle state updates
      if (type == 'state') {
        final payload = message['payload'] as Map<String, dynamic>;
        final players = payload['players'] as List<dynamic>? ?? [];
        final bullets = payload['bullets'] as List<dynamic>? ?? [];
        
        // Detailed state logging
        if (players.length > 1 || bullets.isNotEmpty) {
           final ids = players.map((p) => p['id']).toList();
           print("NET_DEBUG: State received. Players: $ids. My ID: $_localPlayerId");
           
           if (_localPlayerId != null) {
              final myData = players.firstWhere((p) => p['id'] == _localPlayerId, orElse: () => null);
              if (myData != null) {
                print("NET_DEBUG: Server sees me at (${myData['x']}, ${myData['y']})");
              }
           }
        }
        
        _updateRemotePlayers(players);
        _updateRemoteBullets(bullets);
        _updateLocalPlayerFromServer(players);
      }
    });
  }
  
  void _updateRemotePlayers(List<dynamic> players) {
    // Don't render anyone until we know our own ID
    if (_localPlayerId == null) return;
    
    final activeIds = <String>{};
    
    for (final p in players) {
      final id = p['id'] as String;
      final x = (p['x'] as num).toDouble();
      final y = (p['y'] as num).toDouble();
      final rotation = (p['rotation'] as num?)?.toDouble() ?? 0.0;
      final name = p['name'] as String? ?? 'Player';
      
      // Skip local player
      if (id == _localPlayerId) continue;
      
      activeIds.add(id);
      
      if (_remotePlayers.containsKey(id)) {
        // Update existing remote player
        _remotePlayers[id]!.updateFromServer(x, y, rotation);
      } else {
        // Create new remote player
        final remotePlayer = RemotePlayer(
          id: id,
          name: name,
          x: x,
          y: y,
          rotation: rotation,
        );
        _remotePlayers[id] = remotePlayer;
        flameWorld.add(remotePlayer);
      }
    }
    
    // Remove disconnected players
    final toRemove = _remotePlayers.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in toRemove) {
      _remotePlayers[id]?.removeFromParent();
      _remotePlayers.remove(id);
    }
  }
  
  void _updateRemoteBullets(List<dynamic> bullets) {
    if (bullets.isNotEmpty) {
      print("NET_DEBUG: Processing ${bullets.length} remote bullets");
    }
    
    final activeIds = <String>{};
    
    for (final b in bullets) {
      final id = b['id'] as String;
      final x = (b['x'] as num).toDouble();
      final y = (b['y'] as num).toDouble();
      final rotation = (b['rotation'] as num?)?.toDouble() ?? 0.0;
      final ownerId = b['ownerId'] as String? ?? '';
      
      // Skip our own bullets (we render them locally for immediate feedback)
      if (ownerId == _localPlayerId) continue;
      
      activeIds.add(id);
      
      if (_remoteBullets.containsKey(id)) {
        _remoteBullets[id]!.updateFromServer(x, y, rotation);
      } else {
        final remoteBullet = RemoteBullet(
          id: id,
          ownerId: ownerId,
          x: x,
          y: y,
          rotation: rotation,
        );
        _remoteBullets[id] = remoteBullet;
        flameWorld.add(remoteBullet);
      }
    }
    
    // Remove expired bullets
    final toRemove = _remoteBullets.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in toRemove) {
      _remoteBullets[id]?.removeFromParent();
      _remoteBullets.remove(id);
    }
  }
  
  void _updateLocalPlayerFromServer(List<dynamic> players) {
    // Skip if we don't have our ID yet (waiting for welcome message)
    if (_localPlayerId == null) return;
    
    // Update local player from server (authoritative)
    for (final p in players) {
      if (p['id'] == _localPlayerId) {
        final x = (p['x'] as num).toDouble();
        final y = (p['y'] as num).toDouble();
        final health = (p['health'] as num?)?.toDouble() ?? 100.0;
        
        // Gentle reconciliation (lerp towards server position)
        // If distance is small, just nudge. If large (desync), snap.
        final diffVec = Vector2(x, y) - player.position;
        final dist = diffVec.length;
        
        if (dist > 100) {
          // Hard snap if way off
          player.position = Vector2(x, y);
        } else if (dist > 5) {
          // Gentle nudge (10% per update)
          player.position += diffVec * 0.1;
        }
        
        // Always sync health from server
        player.health = health;
        
        break;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Only spawn enemies in offline mode
    if (!isOnlineMode) {
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
    
    // Send input to server in online mode
    if (isOnlineMode && networkManager != null) {
      final velocity = player.velocity;
      final dx = velocity.x / cfg.playerSpeed;
      final dy = velocity.y / cfg.playerSpeed;
      final rotation = player.angle;
      
      // Check if state changed significantly
      final bool inputChanged = 
          (dx - _lastSentDx).abs() > 0.001 || 
          (dy - _lastSentDy).abs() > 0.001 || 
          (rotation - _lastSentRotation).abs() > 0.01;
          
      if (inputChanged) {
        networkManager!.sendInput(dx: dx, dy: dy, rotation: rotation);
        _lastSentDx = dx;
        _lastSentDy = dy;
        _lastSentRotation = rotation;
      }
    }
  }
  
  /// Called when game is paused to ensure server knows we stopped
  void onGamePaused() {
    if (isOnlineMode && networkManager != null) {
      print("NET_DEBUG: Game paused, sending STOP");
      networkManager!.sendInput(dx: 0, dy: 0, rotation: player.angle);
      _lastSentDx = 0;
      _lastSentDy = 0;
    }
  }
  
  @override
  void onRemove() {
    _stateSubscription?.cancel();
    super.onRemove();
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final worldPos = cameraComponent.viewfinder.globalToLocal(info.eventPosition.global);
    player.lookAt(worldPos);
  }

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
