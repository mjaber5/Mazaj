import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mazaj_radio/mazaj_radio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize just_audio_background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mazaj.radio/audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Initialize notifications
  await NotificationManager().init();

  runApp(const MazajRadio());
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    // Request notification permissions for Android 13+
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showPlayingNotification(String title, String artist) async {
    const androidDetails = AndroidNotificationDetails(
      'audio_playback',
      'Audio Playback',
      channelDescription: 'Notification for audio playback controls',
      ongoing: true,
      actions: [
        AndroidNotificationAction('play', 'Play'),
        AndroidNotificationAction('pause', 'Pause'),
        AndroidNotificationAction('stop', 'Stop'),
      ],
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, artist, notificationDetails);
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}
