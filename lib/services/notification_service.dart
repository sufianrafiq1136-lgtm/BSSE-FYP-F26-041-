import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/batch_model.dart';
import '../models/feed_model.dart';
import 'batch_service.dart';
import 'feed_service.dart';
import 'notification_preferences_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background notification: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FeedService _feedService = FeedService();
  static final BatchService _batchService = BatchService();

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<List<FeedModel>>? _feedSubscription;
  static StreamSubscription<List<BatchModel>>? _batchSubscription;
  static StreamSubscription<NotificationPreferences>? _preferencesSubscription;

  static final Set<String> _lowFeedNotifiedIds = <String>{};
  static final Set<String> _highMortalityNotifiedIds = <String>{};
  static NotificationPreferences _preferences =
      NotificationPreferences.defaults();
  static bool _timeZonesInitialized = false;

  static Future<void> initialize() async {
    _initializeTimeZones();
    await _initializeLocalNotifications();
    await _requestPermission();
    await _configureFirebaseMessaging();
    _watchAuthAndAttachFarmAlerts();
  }

  static void _initializeTimeZones() {
    if (_timeZonesInitialized) {
      return;
    }
    tz_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    const channel = AndroidNotificationChannel(
      'farm_alerts',
      'Farm Alerts',
      description: 'Critical poultry farm alerts',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!_preferences.generalAlerts) {
        return;
      }

      final title = message.notification?.title ?? 'Farm Alert';
      final body = message.notification?.body ?? 'New notification received.';
      await showLocalNotification(title: title, body: body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.messageId}');
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Launched from notification: ${initialMessage.messageId}');
    }

    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');
  }

  static void _watchAuthAndAttachFarmAlerts() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _feedSubscription?.cancel();
      _batchSubscription?.cancel();
      _preferencesSubscription?.cancel();
      _lowFeedNotifiedIds.clear();
      _highMortalityNotifiedIds.clear();
      _preferences = NotificationPreferences.defaults();

      if (user == null) {
        return;
      }

      final userId = user.uid;
      final farmId = user.uid;

      _preferencesSubscription =
          NotificationPreferencesService.streamPreferences(userId).listen((
            prefs,
          ) {
            _preferences = prefs;
          });

      _feedSubscription = _feedService
          .streamFeed(userId: userId, farmId: farmId)
          .listen(_handleFeedAlerts);

      _batchSubscription = _batchService
          .streamBatches(userId: userId, farmId: farmId)
          .listen(_handleBatchAlerts);
    });
  }

  static Future<void> _handleFeedAlerts(List<FeedModel> feedItems) async {
    if (!_preferences.lowFeedAlerts) {
      _lowFeedNotifiedIds.clear();
      return;
    }

    for (final feed in feedItems) {
      if (_feedService.isLowStock(feed) &&
          !_lowFeedNotifiedIds.contains(feed.id)) {
        _lowFeedNotifiedIds.add(feed.id);
        await showLocalNotification(
          title: 'Low Feed Alert',
          body:
              '${feed.name} is low (${feed.quantity.toStringAsFixed(1)} kg left).',
        );
      }
      if (!_feedService.isLowStock(feed)) {
        _lowFeedNotifiedIds.remove(feed.id);
      }
    }
  }

  static Future<void> _handleBatchAlerts(List<BatchModel> batches) async {
    if (!_preferences.mortalityAlerts) {
      _highMortalityNotifiedIds.clear();
      return;
    }

    for (final batch in batches) {
      if (_batchService.isHighMortality(batch) &&
          !_highMortalityNotifiedIds.contains(batch.id)) {
        _highMortalityNotifiedIds.add(batch.id);
        await showLocalNotification(
          title: 'High Mortality Alert',
          body:
              '${batch.name} mortality is ${batch.mortalityRate.toStringAsFixed(1)}%.',
        );
      }
      if (!_batchService.isHighMortality(batch)) {
        _highMortalityNotifiedIds.remove(batch.id);
      }
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'farm_alerts',
        'Farm Alerts',
        channelDescription: 'Critical poultry farm alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static Future<void> scheduleTodoReminder({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool repeatDaily,
  }) async {
    _initializeTimeZones();

    final scheduledDate = repeatDaily
        ? _nextDailyTime(scheduledAt)
        : tz.TZDateTime.from(scheduledAt.toUtc(), tz.UTC);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'farm_alerts',
        'Farm Alerts',
        channelDescription: 'Critical poultry farm alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _localNotifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }

  static Future<void> cancelScheduledNotification(int notificationId) async {
    await _localNotifications.cancel(notificationId);
  }

  static tz.TZDateTime _nextDailyTime(DateTime scheduledAt) {
    final now = DateTime.now();
    final todayAtTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledAt.hour,
      scheduledAt.minute,
    );

    final next = todayAtTime.isAfter(now)
        ? todayAtTime
        : todayAtTime.add(const Duration(days: 1));

    return tz.TZDateTime.from(next.toUtc(), tz.UTC);
  }
}
