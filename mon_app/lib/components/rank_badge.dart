import 'package:flutter/material.dart';
import '../utils/rank_utils.dart';

class RankBadge extends StatelessWidget {
  final String rank;
  final int? level;

  const RankBadge({super.key, required this.rank, this.level});

  @override
  Widget build(BuildContext context) {
    final color = rankColor(rank);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            level != null ? '$rank  ·  Niv. $level' : rank,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
