import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onPlay;
  final void Function(String serverIp)? onMultiplayer;

  const MenuScreen({super.key, required this.onPlay, this.onMultiplayer});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _showIpInput = false;
  final _ipController = TextEditingController(text: 'localhost');

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
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
          child: _showIpInput ? _buildIpInputScreen() : _buildMainMenu(),
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Column(
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
        
        // Single Player Button
        _MenuButton(
          label: 'TEK OYUNCU',
          color: Colors.cyan,
          onTap: widget.onPlay,
        ),
        const SizedBox(height: 20),
        
        // Multiplayer Button
        if (widget.onMultiplayer != null)
          _MenuButton(
            label: 'ÇOK OYUNCU',
            color: Colors.green,
            onTap: () => setState(() => _showIpInput = true),
          ),
        if (widget.onMultiplayer != null)
          const SizedBox(height: 20),
        
        // Quit Button
        _MenuButton(
          label: 'ÇIKIŞ',
          color: Colors.red.shade400,
          onTap: () => SystemNavigator.pop(),
        ),
      ],
    );
  }

  Widget _buildIpInputScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'SUNUCU BAĞLANTISI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 40),
        
        // IP Input Field
        SizedBox(
          width: 300,
          child: TextField(
            controller: _ipController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Sunucu IP',
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: 'örn: 192.168.1.5',
              hintStyle: const TextStyle(color: Colors.white24),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back Button
            _MenuButton(
              label: 'GERİ',
              color: Colors.grey,
              onTap: () => setState(() => _showIpInput = false),
            ),
            const SizedBox(width: 20),
            // Connect Button
            _MenuButton(
              label: 'BAĞLAN',
              color: Colors.green,
              onTap: () {
                final ip = _ipController.text.trim();
                if (ip.isNotEmpty) {
                  widget.onMultiplayer?.call(ip);
                }
              },
            ),
          ],
        ),
      ],
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
