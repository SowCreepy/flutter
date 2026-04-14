import 'dart:async';
import 'package:flutter/material.dart';
import '../components/invitation_card.dart';
import '../services/invitation_store.dart';
import '../services/socket_service.dart';
import '../services/api_client.dart';
import '../models/sent_invitation.dart';

class MatchmakingPage extends StatefulWidget {
  const MatchmakingPage({super.key});

  @override
  State<MatchmakingPage> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final _store = InvitationStore.instance;
  StreamSubscription? _invSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    ApiClient.instance.patch('/players/me/availability', {'isAvailable': true});

    _store.fetchReceived().then((_) {
      if (mounted) setState(() {});
    });

    _invSub = SocketService.instance.onInvitationReceived.listen((data) {
      _store.fetchReceived().then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _invSub?.cancel();
    ApiClient.instance.patch('/players/me/availability', {
      'isAvailable': false,
    });
    super.dispose();
  }

  Future<void> _acceptInvitation(SentInvitation inv) async {
    final chatId = await _store.accept(inv.id);
    if (chatId != null && mounted) {
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: <String, String>{
          'chatId': chatId,
          'username': inv.player.username,
          'rank': inv.player.rank,
        },
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _rejectInvitation(SentInvitation inv) async {
    await _store.reject(inv.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mode Solo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),

              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) =>
                    Transform.scale(scale: _pulseAnimation.value, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6FFF).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C6FFF).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_search_rounded,
                    size: 56,
                    color: Color(0xFF7C6FFF),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'En attente...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous êtes visible pour les groupes\nqui cherchent un dernier joueur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              if (_store.received.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'INVITATIONS (${_store.received.length})',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_store.received.length, (i) {
                  final inv = _store.received[i];
                  return InvitationCard(
                    username: inv.player.username,
                    rank: inv.player.rank,
                    subtitle: '${inv.player.rank}  ·  Niv. ${inv.player.level}',
                    onAccept: () => _acceptInvitation(inv),
                    onReject: () => _rejectInvitation(inv),
                  );
                }),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
