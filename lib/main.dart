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
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.mazaj.radio.audio',
        androidNotificationChannelName: 'Mazaj Radio Playback',
        androidNotificationChannelDescription: 'Control Mazaj Radio playback',
        androidNotificationOngoing: true,
        androidNotificationClickStartsActivity: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon:
            'mipmap/ic_notification', // Custom notification icon
        androidShowNotificationBadge: true,
        notificationColor: AppColors.accentColor, // Branded color
        preloadArtwork: true,
        artDownscaleWidth: 128, // Higher quality images
        artDownscaleHeight: 128,
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
