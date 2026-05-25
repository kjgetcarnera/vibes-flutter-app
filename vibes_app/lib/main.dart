import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/services/audio_service_manager.dart';
import 'core/services/vibes_audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise audio_service — this sets up the foreground service on Android
  // and registers the media session on iOS so lock screen controls work.
  final handler = await AudioService.init<VibesAudioHandler>(
    builder: () => VibesAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.carnera.vibes.audio',
      androidNotificationChannelName: 'MANTRA Audio',
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  AudioServiceManager.instance.setHandler(handler);

  runApp(const VibesApp());
}
