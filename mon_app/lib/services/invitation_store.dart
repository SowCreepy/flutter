import 'package:flutter/foundation.dart';
import '../models/sent_invitation.dart';
import '../models/player.dart';
import 'api_client.dart';

class InvitationStore extends ChangeNotifier {
  InvitationStore._();
  static final InvitationStore instance = InvitationStore._();

  List<SentInvitation> sent = [];
  List<SentInvitation> received = [];
  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchSent() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiClient.instance.getList('/invitations/sent');
      sent = data.map((j) => SentInvitation.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error fetching sent invitations: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReceived() async {
    try {
      final data = await ApiClient.instance.getList('/invitations/received');
      received = data.map((j) => SentInvitation.fromJson(j)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching received invitations: $e');
    }
  }

  Future<void> add(Player player) async {
    try {
      final data = await ApiClient.instance.post('/invitations', {
        'receiverId': player.id,
      });
      sent.add(SentInvitation.fromJson(data));
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      rethrow;
    }
  }

  Future<String?> accept(String invitationId) async {
    try {
      final data = await ApiClient.instance.patch(
        '/invitations/$invitationId/accept',
      );
      final idx = received.indexWhere((i) => i.id == invitationId);
      if (idx != -1) {
        received[idx].status = InvitationStatus.accepted;
      }
      notifyListeners();
      return data['chatId'] as String?;
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      return null;
    }
  }

  Future<void> reject(String invitationId) async {
    try {
      await ApiClient.instance.patch('/invitations/$invitationId/reject');
      received.removeWhere((i) => i.id == invitationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error rejecting invitation: $e');
    }
  }

  bool hasInvited(String playerId) => sent.any((i) => i.player.id == playerId);

  int get pendingCount =>
      sent.where((i) => i.status == InvitationStatus.pending).length;

  void clear() {
    sent.clear();
    received.clear();
    notifyListeners();
  }
}
