import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final int finalScore;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.finalScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Over Title
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 8,
                shadows: [
                  Shadow(color: Colors.red, blurRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Final Score
            const Text(
              'FINAL SCORE',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              finalScore.toString().padLeft(6, '0'),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(color: Colors.amber, blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Restart Button
            _RestartButton(onTap: onRestart),
          ],
        ),
      ),
    );
  }
}

class _RestartButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RestartButton({required this.onTap});

  @override
  State<_RestartButton> createState() => _RestartButtonState();
}

class _RestartButtonState extends State<_RestartButton> {
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
            color: _isHovered ? Colors.red.withOpacity(0.3) : Colors.transparent,
            border: Border.all(
              color: Colors.red,
              width: _isHovered ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)]
                : [],
          ),
          child: const Center(
            child: Text(
              'RESTART',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
