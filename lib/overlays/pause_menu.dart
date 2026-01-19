import 'package:flutter/material.dart';

class PauseMenuOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onSettings;
  final VoidCallback onQuit;

  const PauseMenuOverlay({
    super.key,
    required this.onResume,
    required this.onSettings,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 50),
            _MenuButton(text: 'RESUME', onTap: onResume, color: Colors.green),
            const SizedBox(height: 16),
            _MenuButton(text: 'SETTINGS', onTap: onSettings, color: Colors.blue),
            const SizedBox(height: 16),
            _MenuButton(text: 'QUIT', onTap: onQuit, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _MenuButton({required this.text, required this.onTap, required this.color});

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
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withOpacity(0.3) : Colors.transparent,
            border: Border.all(color: widget.color, width: _isHovered ? 3 : 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.color,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
