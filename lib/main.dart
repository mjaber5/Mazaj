import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/mazaj_radio.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mazaj.radio/audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );

  final audioPlayerCubit = AudioPlayerCubit();
  await NotificationManager(audioPlayerCubit).init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AudioPlayerCubit>.value(value: audioPlayerCubit),
        ChangeNotifierProvider(create: (_) => RadioProvider()),
      ],
      child: const MazajRadio(),
    ),
  );
}

class NotificationManager {
  AudioPlayerCubit _audioPlayerCubit;
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager(AudioPlayerCubit cubit) {
    _instance._audioPlayerCubit = cubit;
    return _instance;
  }
  NotificationManager._internal() : _audioPlayerCubit = AudioPlayerCubit();

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
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload != null) {
          final parts = payload.split('|');
          final action = parts[0];
          final radioId = parts[1];
          final radio = _audioPlayerCubit.state.currentRadio;

          if (radio != null && radio.id == radioId) {
            switch (action) {
              case 'play':
                await _audioPlayerCubit.playRadio(
                  radio,
                  _audioPlayerCubit.context,
                );
                break;
              case 'pause':
                await _audioPlayerCubit.pauseRadio(_audioPlayerCubit.context);
                break;
              case 'stop':
                await _audioPlayerCubit.stopRadio(_audioPlayerCubit.context);
                break;
            }
          }
        }
      },
    );

    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showPlayingNotification(
    String title,
    String artist,
    String radioId,
    String logo,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'audio_playback',
      'Audio Playback',
      channelDescription: 'Notification for audio playback controls',
      ongoing: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      actions: [
        AndroidNotificationAction(
          'play',
          'Play',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'pause',
          'Pause',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'stop',
          'Stop',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: MediaStyleInformation(),
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      title,
      artist,
      notificationDetails,
      payload: 'play|$radioId',
    );
  }

  Future<void> updateNotification(
    String title,
    String artist,
    String radioId,
    bool isPlaying,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'audio_playback',
      'Audio Playback',
      channelDescription: 'Notification for audio playback controls',
      ongoing: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      actions: [
        AndroidNotificationAction(
          'play',
          'Play',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'pause',
          'Pause',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'stop',
          'Stop',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: MediaStyleInformation(),
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      title,
      artist,
      notificationDetails,
      payload: (isPlaying ? 'pause' : 'play') + '|$radioId',
    );
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}
