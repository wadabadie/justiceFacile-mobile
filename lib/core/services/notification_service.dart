import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _fcm   = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // Provided by the app once the router is mounted.
  void Function(String route, {Object? extra})? _navigate;

  // Tap from a terminated app arrives before the router is ready — held here.
  RemoteMessage? _pendingMessage;

  static const _kFcmToken = 'fcm_token';

  static const _channel = AndroidNotificationChannel(
    'justice_facile_channel',
    'JusticeFacile',
    description: 'Notifications JusticeFacile',
    importance: Importance.high,
  );

  /// Call this from [JusticeFacileApp.initState] right after the router is built.
  void setNavigate(void Function(String route, {Object? extra}) fn) {
    _navigate = fn;
    if (_pendingMessage != null) {
      _handleMessage(_pendingMessage!);
      _pendingMessage = null;
    }
  }

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    // Foreground: show a local notification banner.
    FirebaseMessaging.onMessage.listen(_showLocal);

    // Background tap: app was backgrounded, user tapped the system notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Terminated tap: app was killed, tapped notification relaunches it.
    // Router isn't ready yet — store and flush in setNavigate().
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _pendingMessage = initial;

    await _registerToken();
    _fcm.onTokenRefresh.listen(_sendToken);
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _handleMessage(RemoteMessage message) {
    if (_navigate == null) {
      _pendingMessage = message;
      return;
    }
    _route(message.data);
  }

  void _onLocalTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) {
      _navigate?.call('/notifications');
      return;
    }
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      _route(data);
    } catch (_) {
      _navigate?.call('/notifications');
    }
  }

  void _route(Map<String, dynamic> data) {
    final route = data['route'] as String? ?? '/notifications';
    switch (route) {
      case '/chat':
        final dossierId = int.tryParse(data['dossierId']?.toString() ?? '') ?? 0;
        final canal       = data['canal']       as String? ?? 'juriste';
        final contactName = data['contactName'] as String? ?? 'Spécialiste';
        _navigate?.call('/chat', extra: {
          'dossierId':   dossierId,
          'canal':       canal,
          'contactName': contactName,
        });
      case '/dossier-detail':
        // Full DossierEntity not available in push payload — go to the list.
        _navigate?.call('/dossiers');
      default:
        _navigate?.call(route);
    }
  }

  // ── Foreground local notification ──────────────────────────────────────────

  void _showLocal(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    _local.show(
      id: message.hashCode,
      title: notif.title ?? 'JusticeFacile',
      body: notif.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      // Routing data encoded as payload so _onLocalTap can navigate correctly.
      payload: jsonEncode(message.data),
    );
  }

  // ── API helpers ────────────────────────────────────────────────────────────

  Future<int> fetchUnreadCount() async {
    try {
      final res = await ApiService.instance.get(ApiConstants.notificationsNonLues);
      return (res.data['non_lues'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_kFcmToken) == token) return;
      await _sendToken(token);
    } catch (_) {}
  }

  Future<void> _sendToken(String token) async {
    try {
      await ApiService.instance.post(
        ApiConstants.fcmToken,
        data: {'token': token, 'platform': 'android'},
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFcmToken, token);
    } catch (_) {}
  }

  // ── Test helpers ───────────────────────────────────────────────────────────

  Future<void> testNotification() => _local.show(
        id: 999,
        title: 'JusticeFacile — Test',
        body: 'Les notifications fonctionnent correctement ✓',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );

  Future<String?> getFcmToken() => _fcm.getToken();
}
