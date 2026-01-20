import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../game/war_at_grid_game.dart';
import '../game/components/player.dart';
import '../config.dart';
import 'touch_controls.dart';

/// Check if running on mobile platform
bool get isMobile {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
         defaultTargetPlatform == TargetPlatform.iOS;
}

class HudOverlay extends StatelessWidget {
  final WarAtGridGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // HUD info at top
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthBar(),
                  const SizedBox(height: 8),
                  _buildAmmoDisplay(),
                  const SizedBox(height: 8),
                  _buildDashCooldown(),
                  const SizedBox(height: 4),
                  _buildGrenadeCooldown(),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWeaponMode(),
                  const SizedBox(height: 8),
                  _buildScore(),
                ],
              ),
            ],
          ),
        ),
        
        // Pause button for mobile (top-right)
        if (isMobile)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                game.onPauseToggle?.call();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.pause, color: Colors.white, size: 24),
              ),
            ),
          ),
        
        // Touch controls for mobile
        if (isMobile) TouchControls(game: game),
      ],
    );
  }

  Widget _buildHealthBar() {
    double healthPercent;
    try { healthPercent = game.player.healthPercent; } catch (_) { healthPercent = 1.0; }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('HEALTH', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 4),
        Container(
          width: 200, height: 20,
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: healthPercent,
            child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade900, Colors.red.shade600]), borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }

  Widget _buildAmmoDisplay() {
    int ammo; bool reloading;
    try { ammo = game.player.currentAmmo; reloading = game.player.isReloading; } 
    catch (_) { ammo = cfg.magazineSize; reloading = false; }
    return Row(
      children: [
        Text(reloading ? 'RELOADING...' : 'AMMO', style: TextStyle(color: reloading ? Colors.yellow : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(width: 8),
        if (!reloading) Text('$ammo / ${cfg.magazineSize}', style: TextStyle(color: ammo > 3 ? Colors.white : Colors.red, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildDashCooldown() {
    double progress; try { progress = game.player.dashCooldownProgress; } catch (_) { progress = 1.0; }
    final isReady = progress >= 1.0;
    return Row(children: [
      Text(isReady ? 'DASH ✓' : 'DASH', style: TextStyle(color: isReady ? Colors.cyanAccent : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(width: 8),
      Container(width: 80, height: 8, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
        child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: progress, child: Container(decoration: BoxDecoration(color: isReady ? Colors.cyan : Colors.grey, borderRadius: BorderRadius.circular(3))))),
    ]);
  }

  Widget _buildGrenadeCooldown() {
    double progress; try { progress = game.player.grenadeCooldownProgress; } catch (_) { progress = 1.0; }
    final isReady = progress >= 1.0;
    return Row(children: [
      Text(isReady ? 'NADE ✓' : 'NADE', style: TextStyle(color: isReady ? Colors.orangeAccent : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(width: 8),
      Container(width: 80, height: 8, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
        child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: progress, child: Container(decoration: BoxDecoration(color: isReady ? Colors.orange : Colors.grey, borderRadius: BorderRadius.circular(3))))),
    ]);
  }

  Widget _buildWeaponMode() {
    WeaponMode mode; try { mode = game.player.weaponMode; } catch (_) { mode = WeaponMode.gun; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: mode == WeaponMode.gun ? Colors.grey.shade800 : Colors.cyan.shade900, borderRadius: BorderRadius.circular(4), border: Border.all(color: mode == WeaponMode.gun ? Colors.grey : Colors.cyan)),
      child: Text(mode == WeaponMode.gun ? '🔫 GUN' : '🔪 KNIFE', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildScore() {
    int score; try { score = game.player.score; } catch (_) { score = 0; }
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const Text('SCORE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 4),
      Text(score.toString().padLeft(6, '0'), style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'monospace', shadows: [Shadow(color: Colors.amber, blurRadius: 8)])),
    ]);
  }
}

