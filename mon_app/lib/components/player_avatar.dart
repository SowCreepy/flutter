import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  final String username;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  const PlayerAvatar({
    super.key,
    required this.username,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF7C6FFF).withOpacity(0.2),
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: const Color(0xFF7C6FFF),
            fontSize: size * 0.33,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
