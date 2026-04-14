import 'dart:async';
import 'package:flutter/material.dart';
import '../services/invitation_store.dart';
import '../services/socket_service.dart';
import '../models/sent_invitation.dart';
import '../components/invitation_card.dart';

class InvitationsSentPage extends StatefulWidget {
  const InvitationsSentPage({super.key});

  @override
  State<InvitationsSentPage> createState() => _InvitationsSentPageState();
}

class _InvitationsSentPageState extends State<InvitationsSentPage> {
  final _store = InvitationStore.instance;
  bool _loading = true;
  StreamSubscription? _acceptSub;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
    _acceptSub = SocketService.instance.onInvitationAccepted.listen((data) {
      final chatId = data['chatId'] as String?;
      final by = data['by'] as Map<String, dynamic>?;
      if (chatId != null && mounted) {
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: <String, String>{
            'chatId': chatId,
            'username': by?['username']?.toString() ?? 'Joueur',
            'rank': by?['rank']?.toString() ?? '',
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _acceptSub?.cancel();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    await _store.fetchSent();
    if (mounted) setState(() => _loading = false);
  }

  void _goToChat(SentInvitation inv) {
    if (inv.chatId == null) return;
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: <String, String>{
        'chatId': inv.chatId!,
        'username': inv.player.username,
        'rank': inv.player.rank,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invitations = _store.sent;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Invitations envoyées',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C6FFF)),
            )
          : invitations.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune invitation envoyée',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Swipez des joueurs pour les inviter.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: invitations.length,
              itemBuilder: (context, i) {
                final inv = invitations[i];
                return InvitationCard(
                  username: inv.player.username,
                  rank: inv.player.rank,
                  subtitle: '${inv.player.rank}  ·  Niv. ${inv.player.level}',
                  status: inv.isAccepted
                      ? InviteCardStatus.accepted
                      : InviteCardStatus.pending,
                  onChat: inv.isAccepted ? () => _goToChat(inv) : null,
                );
              },
            ),
    );
  }
}
