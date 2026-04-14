import 'package:flutter/material.dart';

class SwipeOverlay extends StatelessWidget {
  final bool showInvite;
  final bool showSkip;

  const SwipeOverlay({
    super.key,
    required this.showInvite,
    required this.showSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (!showInvite && !showSkip) return const SizedBox.shrink();

    final color = showInvite
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF5252);
    final label = showInvite ? 'INVITER' : 'PASSER';
    final angle = showInvite ? -0.3 : 0.3;
    final alignment = showInvite ? Alignment.topLeft : Alignment.topRight;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: alignment,
            child: Transform.rotate(
              angle: angle,
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
