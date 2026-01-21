import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/war_at_grid_game.dart';
import 'overlays/hud.dart';
import 'overlays/game_over.dart';
import 'overlays/pause_menu.dart';
import 'screens/menu_screen.dart';
import 'screens/settings_screen.dart';
import 'network/network_manager.dart';

void main() {
  runApp(const WarAtGridApp());
}

class WarAtGridApp extends StatelessWidget {
  const WarAtGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WarAtGrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainNavigator(),
    );
  }
}

enum AppState { menu, playing, paused, settings, gameOver }

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  AppState _appState = AppState.menu;
  WarAtGridGame? _game;
  int _finalScore = 0;
  final NetworkManager _networkManager = NetworkManager();
  bool _isOnlineMode = false;

  void _startGame() {
    setState(() {
      _isOnlineMode = false;
      _game = WarAtGridGame(onPauseToggle: _togglePause);
      _appState = AppState.playing;
    });
  }
  
  @override
  void dispose() {
    _networkManager.dispose();
    super.dispose();
  }
  
  Future<void> _startMultiplayer(String serverIp, String playerName) async {
    // Sunucuya bağlan
    final success = await _networkManager.connect(serverIp);
    
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sunucuya bağlanılamadı!'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    
    // Oyunu başlat
    setState(() {
      _isOnlineMode = true;
      _game = WarAtGridGame(
        onPauseToggle: _togglePause,
        networkManager: _networkManager,
      );
      _appState = AppState.playing;
    });
    
    // Sunucuya katılma mesajı gönder
    _networkManager.sendJoin(playerName);
  }
  
  void _togglePause() {
    if (_appState == AppState.playing) {
      _pauseGame();
    } else if (_appState == AppState.paused) {
      _resumeGame();
    }
  }

  void _pauseGame() {
    _game?.onGamePaused();
    setState(() => _appState = AppState.paused);
    _game?.paused = true;
  }

  void _resumeGame() {
    setState(() => _appState = AppState.playing);
    _game?.paused = false;
  }

  void _openSettings() {
    _game?.onGamePaused();
    setState(() => _appState = AppState.settings);
  }

  void _closeSettings() {
    setState(() => _appState = AppState.paused);
  }

  void _quitToMenu() {
    // Disconnect from server if in online mode
    if (_isOnlineMode) {
      _networkManager.disconnect();
      _isOnlineMode = false;
    }
    
    setState(() {
      _game = null;
      _appState = AppState.menu;
    });
  }

  void _onGameOver(int score) {
    setState(() {
      _finalScore = score;
      _appState = AppState.gameOver;
    });
  }

  void _restartGame() {
    setState(() {
      _game = WarAtGridGame(onPauseToggle: _togglePause);
      _appState = AppState.playing;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_appState) {
      case AppState.menu:
        return MenuScreen(
          onPlay: _startGame,
          onMultiplayer: _startMultiplayer,
        );
        
      case AppState.settings:
        return SettingsScreen(onBack: _closeSettings);
        
      case AppState.gameOver:
        return GameOverOverlay(finalScore: _finalScore, onRestart: _restartGame);
        
      case AppState.playing:
      case AppState.paused:
        return _buildGameScreen();
    }
  }

  Widget _buildGameScreen() {
    // No extra Focus widget needed, GameWidget handles it via mixins
    return Scaffold(
      body: Stack(
        children: [
          if (_game != null) GameWidget(game: _game!), // Ensure game exists
          if (_game != null) _GameStateWrapper(game: _game!, onGameOver: _onGameOver),
          if (_appState == AppState.paused)
            PauseMenuOverlay(
              onResume: _resumeGame,
              onSettings: _openSettings,
              onQuit: _quitToMenu,
            ),
        ],
      ),
    );
  }
}

class _GameStateWrapper extends StatefulWidget {
  final WarAtGridGame game;
  final void Function(int score) onGameOver;

  const _GameStateWrapper({required this.game, required this.onGameOver});

  @override
  State<_GameStateWrapper> createState() => _GameStateWrapperState();
}

class _GameStateWrapperState extends State<_GameStateWrapper> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  bool _gameOverTriggered = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      try {
        if (!widget.game.player.isAlive && !_gameOverTriggered) {
          _gameOverTriggered = true;
          widget.onGameOver(widget.game.player.score);
        }
      } catch (_) {}
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HudOverlay(game: widget.game);
  }
}
