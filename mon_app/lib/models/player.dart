class MatchResult {
  final String? id;
  final bool isWin;
  final String map;
  final int kills;
  final int deaths;
  final DateTime? playedAt;

  const MatchResult({
    this.id,
    required this.isWin,
    required this.map,
    required this.kills,
    required this.deaths,
    this.playedAt,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      id: json['id'],
      isWin: json['isWin'] as bool,
      map: json['map'] as String,
      kills: json['kills'] as int,
      deaths: json['deaths'] as int,
      playedAt: json['playedAt'] != null
          ? DateTime.parse(json['playedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'isWin': isWin,
    'map': map,
    'kills': kills,
    'deaths': deaths,
  };
}

class Player {
  final String id;
  final String username;
  final String rank;
  final int level;
  final int elo;
  final String? steamUrl;
  final bool isAvailable;
  final List<MatchResult> recentMatches;

  const Player({
    required this.id,
    required this.username,
    required this.rank,
    required this.level,
    this.elo = 0,
    this.steamUrl,
    this.isAvailable = false,
    this.recentMatches = const [],
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      username: json['username'] as String,
      rank: json['rank'] as String? ?? 'Silver I',
      level: json['level'] as int? ?? 1,
      elo: json['elo'] as int? ?? 0,
      steamUrl: json['steamUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? false,
      recentMatches:
          (json['recentMatches'] as List<dynamic>?)
              ?.map((m) => MatchResult.fromJson(m))
              .toList() ??
          (json['matches'] as List<dynamic>?)
              ?.map((m) => MatchResult.fromJson(m))
              .toList() ??
          [],
    );
  }

  bool get lastMatchWin =>
      recentMatches.isNotEmpty && recentMatches.first.isWin;
}
