import 'package:flutter/material.dart';
import '../models/player.dart';
import 'player_avatar.dart';
import 'rank_badge.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              PlayerAvatar(username: player.username, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: player.isAvailable
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          player.isAvailable ? 'Disponible' : 'Occupé',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RankBadge(rank: player.rank, level: player.level),
          const SizedBox(height: 20),
          if (player.recentMatches.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: player.lastMatchWin
                    ? const Color(0xFF1E4D2B)
                    : const Color(0xFF4D1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    player.lastMatchWin
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: player.lastMatchWin
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5252),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    player.lastMatchWin
                        ? 'Dernier match : Victoire'
                        : 'Dernier match : Défaite',
                    style: TextStyle(
                      color: player.lastMatchWin
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5252),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'DERNIÈRES PARTIES',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ...player.recentMatches.take(3).map((m) => _MatchRow(match: m)),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final MatchResult match;

  const _MatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: match.isWin
                  ? const Color(0xFF1E4D2B)
                  : const Color(0xFF4D1E1E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                match.isWin ? 'V' : 'D',
                style: TextStyle(
                  color: match.isWin
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              match.map,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '${match.kills}/${match.deaths}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
