import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _invitationChannelId = 'mona_invitations';
  static const _messageChannelId = 'mona_messages';

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);

    // Demande la permission sur Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showInvitation(String senderUsername) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _invitationChannelId,
        'Invitations',
        channelDescription: 'Notifications pour les invitations reçues',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      1000,
      'Nouvelle invitation 🎮',
      '$senderUsername vous invite à jouer !',
      details,
    );
  }

  Future<void> showMessage(String senderUsername, String content) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _messageChannelId,
        'Messages',
        channelDescription: 'Notifications pour les nouveaux messages',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(content),
      ),
      iOS: const DarwinNotificationDetails(),
    );
    // Utilise un ID unique par expéditeur pour regrouper les notifications
    await _plugin.show(
      2000 + senderUsername.hashCode.abs() % 1000,
      senderUsername,
      content,
      details,
    );
  }
}
