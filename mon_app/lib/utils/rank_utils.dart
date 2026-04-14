import 'package:flutter/material.dart';

Color rankColor(String rank) {
  if (rank.contains('Silver')) return const Color(0xFF9E9E9E);
  if (rank.contains('Gold Nova')) return const Color(0xFFFFD700);
  if (rank.contains('Master Guardian')) return const Color(0xFF00BCD4);
  if (rank.contains('Distinguished')) return const Color(0xFF2196F3);
  if (rank.contains('Legendary')) return const Color(0xFFFF9800);
  if (rank.contains('Supreme')) return const Color(0xFFE91E63);
  if (rank.contains('Global')) return const Color(0xFFFFD700);
  return const Color(0xFF7C6FFF);
}
