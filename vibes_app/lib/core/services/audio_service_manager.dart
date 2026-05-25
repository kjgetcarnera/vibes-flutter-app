import 'vibes_audio_handler.dart';

/// Singleton that holds the [VibesAudioHandler] instance created at app start.
/// Access anywhere via [AudioServiceManager.instance.handler].
class AudioServiceManager {
  AudioServiceManager._();
  static final AudioServiceManager instance = AudioServiceManager._();

  late VibesAudioHandler handler;

  void setHandler(VibesAudioHandler h) => handler = h;
}
