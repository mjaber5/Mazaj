import 'dart:io' show Platform;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/mazaj_radio.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (Platform.isAndroid) {
    var notificationStatus = await Permission.notification.request();
    debugPrint('Notification permission status: $notificationStatus');
    if (!notificationStatus.isGranted) {
      debugPrint(
        'Notification permission denied; background audio may not work properly',
      );
    }
  }

  MyAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mazaj.radio.audio',
        androidNotificationChannelName: 'Mazaj Radio Playback',
        androidNotificationChannelDescription: 'Control Mazaj Radio playback',
        androidNotificationOngoing: true,
        androidNotificationClickStartsActivity: true,
        androidStopForegroundOnPause: true,
        notificationColor:
            AppColors
                .accentColor, // Example color, use AppColors.accentColor.value
        preloadArtwork: true,
        artDownscaleWidth: 128,
        artDownscaleHeight: 128,
      ),
    );
    debugPrint('AudioService initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize AudioService in main: $e');
    rethrow;
  }

  runApp(MazajRadio(audioHandler: audioHandler));
}
