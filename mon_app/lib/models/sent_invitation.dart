import '../models/player.dart';

enum InvitationStatus { pending, accepted, rejected }

class SentInvitation {
  final String id;
  final Player player;
  InvitationStatus status;
  String? chatId;
  final DateTime createdAt;

  SentInvitation({
    required this.id,
    required this.player,
    this.status = InvitationStatus.pending,
    this.chatId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAccepted => status == InvitationStatus.accepted;

  /// Pour les invitations envoyées (contient le champ `receiver`)
  factory SentInvitation.fromJson(Map<String, dynamic> json) {
    final playerData = json['receiver'] ?? json['sender'] ?? {};
    return SentInvitation(
      id: json['id'] as String,
      player: Player.fromJson(playerData),
      status: _parseStatus(json['status'] as String? ?? 'PENDING'),
      chatId: json['chatId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Pour les invitations reçues (contient le champ `sender`)
  factory SentInvitation.fromJsonReceived(Map<String, dynamic> json) {
    return SentInvitation(
      id: json['id'] as String,
      player: Player.fromJson(json['sender'] as Map<String, dynamic>),
      status: _parseStatus(json['status'] as String? ?? 'PENDING'),
      chatId: json['chatId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static InvitationStatus _parseStatus(String s) {
    switch (s) {
      case 'ACCEPTED':
        return InvitationStatus.accepted;
      case 'REJECTED':
        return InvitationStatus.rejected;
      default:
        return InvitationStatus.pending;
    }
  }
}
