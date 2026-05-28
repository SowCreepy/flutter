import 'dart:async';
import 'package:flutter/material.dart';
import 'pages/profile.dart';
import 'pages/search_last.dart';
import 'pages/messages.dart';
import 'pages/matchmaking.dart';
import 'pages/users.dart';
import 'services/auth_service.dart';
import 'services/invitation_store.dart';
import 'services/notification_service.dart';
import 'services/socket_service.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  StreamSubscription? _invSub;
  StreamSubscription? _msgSub;
  StreamSubscription? _acceptedSub;

  final List<Widget> _pages = const [
    ProfilePage(),
    SearchLastPage(),
    MessagesPage(),
    MatchmakingPage(),
    UsersPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    _invSub = SocketService.instance.onInvitationReceived.listen((data) {
      final invitation = data['invitation'] as Map<String, dynamic>?;
      final sender = invitation?['sender'] as Map<String, dynamic>?;
      final username = sender?['username']?.toString() ?? 'Un joueur';
      NotificationService.instance.showInvitation(username);
    });

    _acceptedSub = SocketService.instance.onInvitationAccepted.listen((data) {
      final chatId = data['chatId'] as String?;
      final invitationId = data['invitationId'] as String?;
      final by = data['by'] as Map<String, dynamic>?;
      final username = by?['username']?.toString() ?? 'Un joueur';
      final rank = by?['rank']?.toString() ?? '';
      final avatarUrl = by?['avatarUrl']?.toString();

      if (invitationId != null && chatId != null) {
        InvitationStore.instance.markAccepted(invitationId, chatId);
      }

      if (chatId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username a accepté ton invitation !'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Ouvrir le chat',
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pushNamed(
                '/chat',
                arguments: <String, String?>{
                  'chatId': chatId,
                  'username': username,
                  'rank': rank,
                  'avatarUrl': avatarUrl,
                },
              ),
            ),
          ),
        );
      }
    });

    _msgSub = SocketService.instance.onChatMessage.listen((data) {
      final msg = data['message'] as Map<String, dynamic>?;
      final senderId =
          msg?['senderId']?.toString() ?? data['senderId']?.toString();
      if (senderId == AuthService.instance.userId) return;
      final senderName =
          msg?['senderUsername']?.toString() ??
          msg?['senderName']?.toString() ??
          'Nouveau message';
      final content =
          msg?['content']?.toString() ?? data['content']?.toString() ?? '';
      if (content.isEmpty) return;
      NotificationService.instance.showMessage(senderName, content);
    });
  }

  @override
  void dispose() {
    _invSub?.cancel();
    _msgSub?.cancel();
    _acceptedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          border: Border(top: BorderSide(color: Color(0xFF2A2A3E), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1A1A2E),
          selectedItemColor: const Color(0xFF7C6FFF),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_add_outlined),
              activeIcon: Icon(Icons.group_add_rounded),
              label: 'Recherche',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_outlined),
              activeIcon: Icon(Icons.person_search_rounded),
              label: 'Solo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Joueurs',
            ),
          ],
        ),
      ),
    );
  }
}
