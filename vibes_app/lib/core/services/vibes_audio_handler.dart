import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart' as audio_session;
import 'package:audioplayers/audioplayers.dart';

class VibesAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Emits when stop() is triggered from the lock screen / notification
  final _externalStopController = StreamController<void>.broadcast();
  Stream<void> get onExternalStop => _externalStopController.stream;

  // Expose raw streams so UI can subscribe without going through playbackState
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<Duration> get durationStream => _player.onDurationChanged;

  PlayerState get currentPlayerState => _player.state;
  Duration get currentPosition => _position;
  Duration get currentDuration => _duration;

  VibesAudioHandler() {
    _configureAudioSession();
    _player.onPlayerStateChanged.listen(_onPlayerStateChanged);
    _player.onPositionChanged.listen(_onPositionChanged);
    _player.onDurationChanged.listen(_onDurationChanged);
  }

  Future<void> _configureAudioSession() async {
    final session = await audio_session.AudioSession.instance;
    await session.configure(audio_session.AudioSessionConfiguration(
      avAudioSessionCategory: audio_session.AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          audio_session.AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: audio_session.AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          audio_session.AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions:
          audio_session.AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const audio_session.AndroidAudioAttributes(
        contentType: audio_session.AndroidAudioContentType.music,
        flags: audio_session.AndroidAudioFlags.none,
        usage: audio_session.AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: audio_session.AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  // Called by _AudioCarouselState when user taps a new track or resumes
  Future<void> playAudio({
    required MediaItem item,
    required String audioUrl,
  }) async {
    // Set media info on lock screen immediately before audio starts
    mediaItem.add(item);
    _broadcastState(processingState: AudioProcessingState.loading);

    _position = Duration.zero;
    _duration = Duration.zero;

    await _player.stop();
    await _player.play(UrlSource(audioUrl));
  }

  void _onPlayerStateChanged(PlayerState state) {
    final playing = state == PlayerState.playing;

    AudioProcessingState processingState;
    if (state == PlayerState.completed) {
      processingState = AudioProcessingState.completed;
    } else if (state == PlayerState.stopped) {
      processingState = AudioProcessingState.idle;
    } else {
      processingState = AudioProcessingState.ready;
    }

    _broadcastState(playing: playing, processingState: processingState);

    if (state == PlayerState.completed) {
      mediaItem.add(null);
    }
  }

  void _onPositionChanged(Duration pos) {
    _position = pos;
    _broadcastState(updatePosition: pos);
  }

  void _onDurationChanged(Duration dur) {
    _duration = dur;
    final current = mediaItem.value;
    if (current != null) {
      mediaItem.add(current.copyWith(duration: dur));
    }
  }

  void _broadcastState({
    bool? playing,
    AudioProcessingState? processingState,
    Duration? updatePosition,
  }) {
    final prev = playbackState.value;
    playbackState.add(prev.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing ?? prev.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [1, 2],
      processingState: processingState ?? prev.processingState,
      playing: playing ?? prev.playing,
      updatePosition: updatePosition ?? prev.updatePosition,
    ));
  }

  // ── BaseAudioHandler overrides (called from lock screen / notification) ──

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
    _broadcastState(
      playing: false,
      processingState: AudioProcessingState.idle,
    );
    // Notify UI so it can clear the active track indicator
    _externalStopController.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  void disposeHandler() {
    _player.dispose();
    _externalStopController.close();
  }
}
