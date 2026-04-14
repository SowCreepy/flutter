import 'package:flutter/material.dart';
import '../models/player.dart';
import '../components/match_tile.dart';
import '../components/primary_button.dart';
import '../components/player_avatar.dart';
import '../components/rank_badge.dart';
import '../components/availability_toggle.dart';
import '../components/stat_box.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import 'edit_profile.dart';
import 'add_match.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Player? _currentPlayer;
  bool _isAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    if (!SocketService.instance.isConnected) {
      SocketService.instance.connect();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiClient.instance.get('/players/me');
      if (!mounted) return;
      setState(() {
        _currentPlayer = Player.fromJson(data);
        _isAvailable = _currentPlayer!.isAvailable;
        _loading = false;
      });
      AuthService.instance.updateUser(data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: $e'),
          backgroundColor: const Color(0xFFFF5252),
        ),
      );
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    try {
      await ApiClient.instance.patch('/players/me/availability', {
        'isAvailable': value,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAvailable = !value);
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    SocketService.instance.disconnect();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  Future<void> _editProfile() async {
    if (_currentPlayer == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(player: _currentPlayer!),
      ),
    );
    if (updated == true) {
      setState(() => _loading = true);
      _loadProfile();
    }
  }

  Future<void> _addMatch() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddMatchPage()),
    );
    if (added == true) {
      setState(() => _loading = true);
      _loadProfile();
    }
  }

  int get _wins =>
      _currentPlayer?.recentMatches.where((m) => m.isWin).length ?? 0;
  int get _losses =>
      _currentPlayer?.recentMatches.where((m) => !m.isWin).length ?? 0;
  String get _winrate {
    if (_currentPlayer == null || _currentPlayer!.recentMatches.isEmpty) {
      return '0%';
    }
    return '${(_wins / _currentPlayer!.recentMatches.length * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C6FFF)),
        ),
      );
    }

    if (_currentPlayer == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Erreur de chargement',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Réessayer',
                icon: Icons.refresh,
                onPressed: () {
                  setState(() => _loading = true);
                  _loadProfile();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mona',
          style: TextStyle(
            color: Color(0xFF7C6FFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white54),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white54),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                PlayerAvatar(
                  username: _currentPlayer!.username,
                  size: 80,
                  borderColor: const Color(0xFF7C6FFF).withOpacity(0.5),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPlayer!.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RankBadge(
                        rank: _currentPlayer!.rank,
                        level: _currentPlayer!.level,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AvailabilityToggle(
              value: _isAvailable,
              onChanged: _toggleAvailability,
            ),
            const SizedBox(height: 20),
            if (_currentPlayer!.elo > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: eloToColor(_currentPlayer!.elo).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: eloToColor(
                          _currentPlayer!.elo,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.military_tech,
                        color: eloToColor(_currentPlayer!.elo),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eloToRank(_currentPlayer!.elo),
                            style: TextStyle(
                              color: eloToColor(_currentPlayer!.elo),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentPlayer!.elo} ELO  •  CS2 Premier',
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
            if (_currentPlayer!.steamUrl != null &&
                _currentPlayer!.steamUrl!.isNotEmpty) ...[
              Container(
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
                    const Icon(Icons.link, color: Color(0xFF66C0F4), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentPlayer!.steamUrl!,
                        style: const TextStyle(
                          color: Color(0xFF66C0F4),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DERNIÈRES PARTIES',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: _addMatch,
                  child: Row(
                    children: [
                      Icon(Icons.add, color: const Color(0xFF7C6FFF), size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: Color(0xFF7C6FFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._currentPlayer!.recentMatches.map(
              (match) => MatchTile(match: match),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
