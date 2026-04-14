import 'package:flutter/material.dart';
import '../models/player.dart';

class MatchTile extends StatelessWidget {
  final MatchResult match;

  const MatchTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 28,
            decoration: BoxDecoration(
              color: match.isWin
                  ? const Color(0xFF1E4D2B)
                  : const Color(0xFF4D1E1E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                match.isWin ? 'V' : 'D',
                style: TextStyle(
                  color: match.isWin
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              match.map,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${match.kills} / ${match.deaths}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
