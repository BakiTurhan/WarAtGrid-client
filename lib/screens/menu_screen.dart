import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuScreen extends StatelessWidget {
  final VoidCallback onPlay;

  const MenuScreen({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'WAR AT GRID',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.cyan,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Survive the Grid',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white54,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 80),
            // Play Button
            _MenuButton(
              label: 'PLAY',
              color: Colors.cyan,
              onTap: onPlay,
            ),
            const SizedBox(height: 20),
            // Quit Button
            _MenuButton(
              label: 'QUIT',
              color: Colors.red.shade400,
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 220,
          height: 55,
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withOpacity(0.3) : Colors.transparent,
            border: Border.all(
              color: widget.color,
              width: _isHovered ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.color,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
