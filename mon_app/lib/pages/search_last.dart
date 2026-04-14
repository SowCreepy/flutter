import 'package:flutter/material.dart';
import '../models/player.dart';
import '../components/player_card.dart';
import '../components/swipe_overlay.dart';
import '../components/swipe_action_button.dart';
import '../services/invitation_store.dart';
import '../services/api_client.dart';

class SearchLastPage extends StatefulWidget {
  const SearchLastPage({super.key});

  @override
  State<SearchLastPage> createState() => _SearchLastPageState();
}

class _SearchLastPageState extends State<SearchLastPage>
    with TickerProviderStateMixin {
  List<Player> _players = [];
  final _store = InvitationStore.instance;
  int _currentIndex = 0;
  double _dragX = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailablePlayers();
  }

  Future<void> _loadAvailablePlayers() async {
    try {
      final data = await ApiClient.instance.getList('/players/available');
      if (!mounted) return;
      setState(() {
        _players = data.map((j) => Player.fromJson(j)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _dragX += details.delta.dx);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragX > 120) {
      _invite();
    } else if (_dragX < -120) {
      _skip();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    final startX = _dragX;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    final anim = Tween<double>(
      begin: startX,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    anim.addListener(() {
      if (mounted) setState(() => _dragX = anim.value);
    });
    controller.forward().then((_) => controller.dispose());
  }

  void _invite() {
    if (_players.isEmpty) return;
    final player = _players[_currentIndex];
    _store
        .add(player)
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invitation envoyée à ${player.username} !'),
                backgroundColor: const Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                action: SnackBarAction(
                  label: 'Voir',
                  textColor: Colors.white,
                  onPressed: () => Navigator.pushNamed(context, '/invitations'),
                ),
              ),
            );
          }
        })
        .catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $e'),
                backgroundColor: const Color(0xFFFF5252),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        });
    _nextCard();
  }

  void _skip() {
    _nextCard();
  }

  void _nextCard() {
    if (_players.isEmpty) return;
    setState(() {
      _dragX = 0;
      _currentIndex = (_currentIndex + 1) % _players.length;
    });
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

    final bool showInvite = _dragX > 50;
    final bool showSkip = _dragX < -50;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chercher un last',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.send_outlined, color: Colors.white70),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/invitations',
                ).then((_) => setState(() {})),
              ),
              if (_store.sent.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C6FFF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_store.sent.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _players.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun joueur disponible',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revenez plus tard !',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '${_currentIndex + 1} / ${_players.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if ((_currentIndex + 1) % _players.length !=
                              _currentIndex)
                            Opacity(
                              opacity: 0.4,
                              child: Transform.scale(
                                scale: 0.95,
                                child: PlayerCard(
                                  player:
                                      _players[(_currentIndex + 1) %
                                          _players.length],
                                ),
                              ),
                            ),
                          Transform.translate(
                            offset: Offset(_dragX, _dragX.abs() * 0.15),
                            child: Transform.rotate(
                              angle: _dragX / 900,
                              child: GestureDetector(
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Stack(
                                  children: [
                                    PlayerCard(player: _players[_currentIndex]),
                                    SwipeOverlay(
                                      showInvite: showInvite,
                                      showSkip: showSkip,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SwipeActionButton(
                            icon: Icons.close_rounded,
                            color: const Color(0xFFFF5252),
                            size: 52,
                            onTap: _skip,
                          ),
                          SwipeActionButton(
                            icon: Icons.favorite_rounded,
                            color: const Color(0xFF7C6FFF),
                            size: 64,
                            onTap: _invite,
                          ),
                          SwipeActionButton(
                            icon: Icons.person_add_rounded,
                            color: const Color(0xFF4CAF50),
                            size: 52,
                            onTap: _invite,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
