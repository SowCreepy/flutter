import 'package:flutter/material.dart';
import 'player_avatar.dart';

enum InviteCardStatus { pending, accepted }

class InvitationCard extends StatelessWidget {
  final String username;
  final String rank;
  final String? subtitle;
  final InviteCardStatus status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onChat;
  const InvitationCard({
    super.key,
    required this.username,
    required this.rank,
    this.subtitle,
    this.status = InviteCardStatus.pending,
    this.onAccept,
    this.onReject,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          PlayerAvatar(username: username, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (onAccept != null || onReject != null)
            Row(
              children: [
                if (onReject != null)
                  _CircleBtn(
                    icon: Icons.close_rounded,
                    color: const Color(0xFFFF5252),
                    onTap: onReject!,
                  ),
                if (onReject != null && onAccept != null)
                  const SizedBox(width: 8),
                if (onAccept != null)
                  _CircleBtn(
                    icon: Icons.check_rounded,
                    color: const Color(0xFF4CAF50),
                    onTap: onAccept!,
                  ),
              ],
            )
          else if (status == InviteCardStatus.accepted)
            Row(
              children: [
                _StatusBadge(label: 'Accepté', color: const Color(0xFF4CAF50)),
                if (onChat != null) ...[
                  const SizedBox(width: 8),
                  _CircleBtn(
                    icon: Icons.chat_bubble_rounded,
                    color: const Color(0xFF7C6FFF),
                    onTap: onChat!,
                  ),
                ],
              ],
            )
          else
            _StatusBadge(label: 'En attente', color: Colors.orange),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
