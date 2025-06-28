import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/mazaj_radio.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mazaj.radio/audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  final audioPlayerCubit = AudioPlayerCubit(audioHandler);
  await NotificationManager(audioHandler, audioPlayerCubit).init();

  runApp(
    MultiProvider(
      providers: [
        Provider<MyAudioHandler>.value(value: audioHandler),
        Provider<AudioPlayerCubit>.value(value: audioPlayerCubit),
        ChangeNotifierProvider(create: (_) => RadioProvider()),
      ],
      child: const MazajRadio(),
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class NotificationManager {
  MyAudioHandler _audioHandler;
  AudioPlayerCubit _audioPlayerCubit;
  static final NotificationManager _instance = NotificationManager._();
  factory NotificationManager(
    MyAudioHandler audioHandler,
    AudioPlayerCubit cubit,
  ) {
    _instance._audioHandler = audioHandler;
    _instance._audioPlayerCubit = cubit;
    return _instance;
  }
  NotificationManager._() // Private constructor for singleton
    : _audioHandler =
          MyAudioHandler(), // Initialize with a default MyAudioHandler
      _audioPlayerCubit = AudioPlayerCubit(
        MyAudioHandler(),
      ); // Initialize with a default AudioPlayerCubit

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationShown = false;

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
                await _audioHandler.play();
                break;
              case 'pause':
                await _audioHandler.pause();
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

    // Listen to media item changes to show or cancel notification
    _audioHandler.mediaItem.listen((mediaItem) async {
      if (mediaItem != null && !_notificationShown) {
        _notificationShown = true;
        await showPlayingNotification(
          mediaItem.title,
          mediaItem.artist ?? '',
          mediaItem.id,
          mediaItem.artUri.toString(),
        );
      } else if (mediaItem == null && _notificationShown) {
        _notificationShown = false;
        await cancelNotification();
      }
    });

    // Listen to playback state to update notification play/pause state with debounce
    _audioHandler.playbackState
        .debounceTime(const Duration(milliseconds: 100))
        .listen((state) async {
          if (_audioPlayerCubit.state.currentRadio != null &&
              _notificationShown) {
            await updateNotification(
              _audioPlayerCubit.state.currentRadio!.name,
              _audioPlayerCubit.state.currentRadio!.genres,
              _audioPlayerCubit.state.currentRadio!.id,
              state.playing,
            );
          }
        });
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
    if (!_notificationShown) return;
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
      payload: '${isPlaying ? 'pause' : 'play'}|$radioId',
    );
  }

  Future<void> cancelNotification() async {
    _notificationShown = false;
    await _notificationsPlugin.cancel(0);
  }
}
