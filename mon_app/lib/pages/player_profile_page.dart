import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/player.dart';
import '../components/match_tile.dart';
import '../components/player_avatar.dart';
import '../components/rank_badge.dart';
import '../components/stat_box.dart';
import '../services/api_client.dart';
import '../services/invitation_store.dart';
import 'edit_profile.dart';

class PlayerProfilePage extends StatefulWidget {
  final String playerId;
  final String? previewUsername;

  const PlayerProfilePage({
    super.key,
    required this.playerId,
    this.previewUsername,
  });

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  Player? _player;
  bool _loading = true;
  bool _inviting = false;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _launchSteamUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir ce lien')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _loadPlayer() async {
    try {
      final data = await ApiClient.instance.get('/players/${widget.playerId}');
      if (!mounted) return;
      setState(() {
        _player = Player.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _sendInvitation() async {
    if (_player == null || _inviting) return;
    setState(() => _inviting = true);
    try {
      await InvitationStore.instance.add(_player!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation envoyée à ${_player!.username} !'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _inviting = false);
    }
  }

  int get _wins => _player?.recentMatches.where((m) => m.isWin).length ?? 0;
  int get _losses => _player?.recentMatches.where((m) => !m.isWin).length ?? 0;
  String get _winrate {
    if (_player == null || _player!.recentMatches.isEmpty) return '0%';
    return '${(_wins / _player!.recentMatches.length * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.previewUsername ?? 'Profil',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C6FFF)),
            )
          : _player == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off_rounded,
                    color: Colors.white24,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Joueur introuvable',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Avatar + nom + rang
                  Row(
                    children: [
                      PlayerAvatar(
                        username: _player!.username,
                        avatarUrl: _player!.avatarUrl,
                        size: 80,
                        borderColor: const Color(0xFF7C6FFF).withOpacity(0.5),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _player!.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            RankBadge(
                              rank: _player!.rank,
                              level: _player!.level,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _player!.isAvailable
                                        ? const Color(0xFF4CAF50)
                                        : Colors.white24,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _player!.isAvailable
                                      ? 'Disponible'
                                      : 'Indisponible',
                                  style: TextStyle(
                                    color: _player!.isAvailable
                                        ? const Color(0xFF4CAF50)
                                        : Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ELO
                  if (_player!.elo > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: eloToColor(_player!.elo).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: eloToColor(_player!.elo).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.military_tech,
                              color: eloToColor(_player!.elo),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  eloToRank(_player!.elo),
                                  style: TextStyle(
                                    color: eloToColor(_player!.elo),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_player!.elo} ELO  •  CS2 Premier',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Steam URL
                  if (_player!.steamUrl != null &&
                      _player!.steamUrl!.isNotEmpty) ...[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _launchSteamUrl(_player!.steamUrl!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.open_in_new_rounded,
                              color: Color(0xFF66C0F4),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _player!.steamUrl!,
                                style: const TextStyle(
                                  color: Color(0xFF66C0F4),
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF66C0F4),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats
                  Row(
                    children: [
                      StatBox(
                        label: 'Victoires',
                        value: '$_wins',
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 12),
                      StatBox(
                        label: 'Défaites',
                        value: '$_losses',
                        color: const Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 12),
                      StatBox(
                        label: 'Winrate',
                        value: _winrate,
                        color: const Color(0xFF7C6FFF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Dernières parties
                  if (_player!.recentMatches.isNotEmpty) ...[
                    Text(
                      'DERNIÈRES PARTIES',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._player!.recentMatches.map(
                      (match) => MatchTile(match: match),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Bouton inviter
                  if (_player!.isAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _inviting ? null : _sendInvitation,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7C6FFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _inviting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          _inviting ? 'Envoi...' : 'Inviter à jouer',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
