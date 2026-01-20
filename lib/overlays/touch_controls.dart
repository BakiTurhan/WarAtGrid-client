import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../game/war_at_grid_game.dart';

/// Mobile touch controls overlay
/// Left: Joystick for movement
/// Right: Action buttons (Fire, Dash, Weapon Change, Ultimate)
class TouchControls extends StatelessWidget {
  final WarAtGridGame game;

  const TouchControls({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LEFT SIDE: Joystick
        Positioned(
          left: 40,
          bottom: 40,
          child: Joystick(
            mode: JoystickMode.all,
            listener: (details) {
              // details.x and details.y are between -1 and 1
              game.player.setMobileMovement(details.x, details.y);
            },
            base: JoystickBase(
              size: 150,
              decoration: JoystickBaseDecoration(
                color: Colors.black.withOpacity(0.3),
                drawOuterCircle: true,
                outerCircleColor: Colors.white.withOpacity(0.3),
              ),
            ),
            stick: JoystickStick(
              size: 60,
              decoration: JoystickStickDecoration(
                color: Colors.blue.withOpacity(0.8),
              ),
            ),
          ),
        ),

        // RIGHT SIDE: Action Buttons
        Positioned(
          right: 40,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ultimate Button (Grenade / Blade Wave)
              _ActionButton(
                icon: Icons.flash_on,
                color: Colors.orange,
                label: 'ULT',
                onTap: () => game.player.secondaryAction(),
              ),
              const SizedBox(height: 12),

              // Weapon Change Button
              _ActionButton(
                icon: Icons.swap_horiz,
                color: Colors.purple,
                label: 'WPN',
                onTap: () => game.player.toggleWeaponMode(),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dash Button
                  _ActionButton(
                    icon: Icons.double_arrow,
                    color: Colors.cyan,
                    label: 'DASH',
                    onTap: () => game.player.dash(),
                  ),
                  const SizedBox(width: 12),

                  // Fire Button (larger)
                  _ActionButton(
                    icon: Icons.gps_fixed,
                    color: Colors.red,
                    label: 'FIRE',
                    size: 80,
                    onTap: () => game.player.primaryAction(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size * 0.4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
