import 'dart:io' show Platform;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/mazaj_radio.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Request necessary permissions
  if (Platform.isAndroid) {
    // Request notification permission
    var notificationStatus = await Permission.notification.request();
    debugPrint('Notification permission status: $notificationStatus');
  }

  MyAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        // Android-specific configuration
        androidNotificationChannelId: 'com.mazaj.radio.audio',
        androidNotificationChannelName: 'Mazaj Radio Audio',
        androidNotificationChannelDescription:
            'Audio playback controls for Mazaj Radio',
        androidNotificationOngoing: true,
        androidNotificationClickStartsActivity: true,
        androidStopForegroundOnPause:
            true, // This must be true when androidNotificationOngoing is true
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidShowNotificationBadge: true,

        // Preload audio for better performance
        preloadArtwork: true,

        // Auto-handling of audio interruptions
        artDownscaleWidth: 64,
        artDownscaleHeight: 64,

        // Faster start time
        fastForwardInterval: Duration(seconds: 10),
        rewindInterval: Duration(seconds: 10),
      ),
    );
    debugPrint('AudioService initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize AudioService in main: $e');
    rethrow;
  }

  runApp(MazajRadio(audioHandler: audioHandler));
}
