import 'package:flutter/material.dart';
import '../config.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeSection = 'PLAYER';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      body: SafeArea(
        child: Row(
          children: [
            // Left sidebar - categories
            Container(
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF151528),
                border: Border(right: BorderSide(color: Colors.cyan.withOpacity(0.3))),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('SETTINGS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _categoryButton('PLAYER', Icons.person),
                        _categoryButton('COMBAT', Icons.sports_mma),
                        _categoryButton('WEAPONS', Icons.flash_on),
                        _categoryButton('ENEMY', Icons.bug_report),
                        _categoryButton('WORLD', Icons.grid_on),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _actionButton('RESET', Colors.orange, () => setState(() => cfg.resetToDefaults())),
                        const SizedBox(height: 8),
                        _actionButton('BACK', Colors.grey, widget.onBack),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: _buildSectionContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(String name, IconData icon) {
    final isActive = _activeSection == name;
    return InkWell(
      onTap: () => setState(() => _activeSection = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyan.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: Colors.cyan.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.cyan : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(name, style: TextStyle(color: isActive ? Colors.cyan : Colors.grey, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
        ),
        child: Text(text, style: const TextStyle(letterSpacing: 2)),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_activeSection) {
      case 'PLAYER':
        return _buildSettingsGrid([
          _SettingItem('Speed', cfg.playerSpeed, 100, 400, (v) => cfg.playerSpeed = v, 'Movement speed'),
          _SettingItem('Health', cfg.playerMaxHealth, 50, 300, (v) => cfg.playerMaxHealth = v, 'Maximum health'),
          _SettingItem('Knife Multiplier', cfg.playerKnifeSpeedMultiplier, 1.0, 3.0, (v) => cfg.playerKnifeSpeedMultiplier = v, 'Speed boost in knife mode'),
          _SettingItem('Damage Cooldown', cfg.playerDamageCooldown, 0.1, 2.0, (v) => cfg.playerDamageCooldown = v, 'Invincibility after hit'),
        ]);
      case 'COMBAT':
        return _buildSettingsGrid([
          _SettingItem('Dash Distance', cfg.dashDistance, 100, 500, (v) => cfg.dashDistance = v, 'How far you dash'),
          _SettingItem('Dash Speed', cfg.dashSpeed, 500, 3000, (v) => cfg.dashSpeed = v, 'Dash movement speed'),
          _SettingItem('Dash Cooldown', cfg.dashCooldown, 0.5, 5.0, (v) => cfg.dashCooldown = v, 'Time between dashes'),
          _SettingItem('Blade Wave Range', cfg.bladeWaveRange, 100, 400, (v) => cfg.bladeWaveRange = v, 'Wave attack distance'),
          _SettingItem('Blade Wave Angle', cfg.bladeWaveAngle, 0.3, 2.0, (v) => cfg.bladeWaveAngle = v, 'Wave attack width'),
          _SettingItem('Blade Wave CD', cfg.bladeWaveCooldown, 1.0, 10.0, (v) => cfg.bladeWaveCooldown = v, 'Blade wave cooldown'),
        ]);
      case 'WEAPONS':
        return _buildSettingsGrid([
          _SettingItem('Magazine Size', cfg.magazineSize.toDouble(), 4, 30, (v) => cfg.magazineSize = v.round(), 'Bullets per magazine'),
          _SettingItem('Reload Time', cfg.reloadTime, 0.5, 4.0, (v) => cfg.reloadTime = v, 'Time to reload'),
          _SettingItem('Bullet Speed', cfg.bulletSpeed, 300, 1200, (v) => cfg.bulletSpeed = v, 'Projectile velocity'),
          _SettingItem('Grenade Radius', cfg.grenadeRadius, 40, 200, (v) => cfg.grenadeRadius = v, 'Explosion size'),
          _SettingItem('Grenade Delay', cfg.grenadeDelay, 1.0, 5.0, (v) => cfg.grenadeDelay = v, 'Fuse time'),
          _SettingItem('Grenade Cooldown', cfg.grenadeCooldown, 5, 30, (v) => cfg.grenadeCooldown = v, 'Time between throws'),
        ]);
      case 'ENEMY':
        return _buildSettingsGrid([
          _SettingItem('Speed', cfg.enemySpeed, 50, 250, (v) => cfg.enemySpeed = v, 'Enemy movement speed'),
          _SettingItem('Damage', cfg.enemyContactDamage, 5, 50, (v) => cfg.enemyContactDamage = v, 'Damage on contact'),
          _SettingItem('Spawn Rate', cfg.enemySpawnInterval, 0.5, 5.0, (v) => cfg.enemySpawnInterval = v, 'Seconds between spawns'),
        ]);
      case 'WORLD':
        return _buildSettingsGrid([
          _SettingItem('View Radius', cfg.viewRadius, 300, 1000, (v) => cfg.viewRadius = v, 'Field of view distance'),
        ]);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSettingsGrid(List<_SettingItem> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildSettingCard(items[index]),
    );
  }

  Widget _buildSettingCard(_SettingItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                child: Text(item.value.toStringAsFixed(1), style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.cyan,
              inactiveTrackColor: Colors.grey.shade800,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: item.value.clamp(item.min, item.max),
              min: item.min,
              max: item.max,
              onChanged: (v) => setState(() => item.onChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final String description;
  
  _SettingItem(this.label, this.value, this.min, this.max, this.onChanged, this.description);
}
