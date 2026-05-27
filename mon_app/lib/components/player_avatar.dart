import 'package:flutter/material.dart';
import '../services/api_client.dart';

class PlayerAvatar extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  const PlayerAvatar({
    super.key,
    required this.username,
    this.avatarUrl,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    Widget inner;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      final url = avatarUrl!.startsWith('http')
          ? avatarUrl!
          : '${ApiClient.staticUrl}$avatarUrl';
      inner = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initials(initials),
      );
    } else {
      inner = _initials(initials);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipOval(child: inner),
    );
  }

  Widget _initials(String initials) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF7C6FFF).withOpacity(0.2),
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
