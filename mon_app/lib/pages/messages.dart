import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final data = await ApiClient.instance.getList('/chats');
      setState(() {
        _chats = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _getOtherUsername(Map<String, dynamic> chat) {
    final myId = AuthService.instance.userId;
    final participants = chat['participants'] as List<dynamic>;
    for (final p in participants) {
      if (p['id'] != myId) return p['username'] ?? 'Joueur';
    }
    return 'Joueur';
  }

  String _getOtherRank(Map<String, dynamic> chat) {
    final myId = AuthService.instance.userId;
    final participants = chat['participants'] as List<dynamic>;
    for (final p in participants) {
      if (p['id'] != myId) return p['rank'] ?? '';
    }
    return '';
  }

  String? _getLastMessage(Map<String, dynamic> chat) {
    final messages = chat['messages'] as List<dynamic>?;
    if (messages == null || messages.isEmpty) return null;
    return messages.first['content'] as String?;
  }

  String _formatTime(Map<String, dynamic> chat) {
    final messages = chat['messages'] as List<dynamic>?;
    String? dateStr;
    if (messages != null && messages.isNotEmpty) {
      dateStr = messages.first['createdAt'] as String?;
    }
    dateStr ??= chat['createdAt'] as String?;
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${date.day}/${date.month}';
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
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C6FFF)),
            )
          : _chats.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune conversation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acceptez une invitation pour commencer à discuter.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF7C6FFF),
              onRefresh: _loadChats,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final username = _getOtherUsername(chat);
                  final rank = _getOtherRank(chat);
                  final lastMsg = _getLastMessage(chat);
                  final time = _formatTime(chat);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C6FFF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          username.length >= 2
                              ? username.substring(0, 2).toUpperCase()
                              : username.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF7C6FFF),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      lastMsg ?? 'Nouvelle conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                    trailing: Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: <String, String>{
                          'chatId': chat['id'] as String,
                          'username': username,
                          'rank': rank,
                        },
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
