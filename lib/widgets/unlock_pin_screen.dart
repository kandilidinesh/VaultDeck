import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:ui';

class UnlockPinScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  const UnlockPinScreen({super.key, this.onCancel});

  @override
  State<UnlockPinScreen> createState() => _UnlockPinScreenState();
}

class _UnlockPinScreenState extends State<UnlockPinScreen> {
  String pin = '';
  String error = '';
  bool isLoading = false;

  void _onKeyTap(String value) {
    setState(() {
      if (pin.length < 4) pin += value;
      error = '';
    });
    if (pin.length == 4) _onSubmit();
  }

  void _onDelete() {
    setState(() {
      if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      error = '';
    });
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        bool filled = i < pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            border: Border.all(
              color: filled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            shape: BoxShape.circle,
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == '') {
                  return const SizedBox(width: 80);
                } else if (key == 'del') {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.withValues(alpha: 0.2),
                          Colors.red.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.backspace_outlined,
                        color: Colors.red[300],
                        size: 28,
                      ),
                      onPressed: _onDelete,
                    ),
                  );
                } else {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () => _onKeyTap(key),
                        child: Center(
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (pin.length < 4) return;
    setState(() {
      isLoading = true;
    });

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    final box = await Hive.openBox('settingsBox');
    final savedPin = box.get('pin');
    if (pin == (savedPin?.toString() ?? '')) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() {
        error = 'Incorrect PIN';
        pin = '';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            ),
          ),
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF000000),
                        const Color(0xFF0A0A0A),
                        const Color(0xFF1A1A1A),
                      ]
                    : [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                        const Color(0xFFf093fb),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),

                  // Header Section
                  Column(
                    children: [
                      // App Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Enter your PIN',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Secure access to your vault',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // PIN Dots
                      _buildPinDots(),

                      // Error Message
                      if (error.isNotEmpty)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red[300],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                error,
                                style: TextStyle(
                                  color: Colors.red[300],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Keypad Section
                  _buildKeypad(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
