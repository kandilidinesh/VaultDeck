import 'package:flutter/material.dart';
import 'dart:ui';

class BlurOverlay extends StatelessWidget {
  final Widget child;
  final bool shouldBlur;

  const BlurOverlay({super.key, required this.child, required this.shouldBlur});

  @override
  Widget build(BuildContext context) {
    if (!shouldBlur) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security_rounded,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
