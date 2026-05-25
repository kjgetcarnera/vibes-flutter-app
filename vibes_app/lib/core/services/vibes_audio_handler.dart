import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart' as audio_session;
import 'package:audioplayers/audioplayers.dart';

/// Pairs a [MediaItem] (lock screen metadata) with the audio URL to stream.
class QueueEntry {
  const QueueEntry({required this.item, required this.audioUrl});
  final MediaItem item;
  final String audioUrl;
}

class VibesAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<QueueEntry> _entries = [];
  int _currentIndex = -1;
  // True while playAudio() is switching tracks internally so the stopped event
  // from _player.stop() doesn't briefly wipe the lock screen artwork.
  bool _isSwitchingTrack = false;

  // Emits when stop() is triggered from the lock screen / notification
  final _externalStopController = StreamController<void>.broadcast();
  Stream<void> get onExternalStop => _externalStopController.stream;

  // Emits the new queue index when the handler skips to next/previous
  final _skipController = StreamController<int>.broadcast();
  Stream<int> get onSkip => _skipController.stream;

  // Expose raw streams so the UI can subscribe directly
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<Duration> get durationStream => _player.onDurationChanged;

  PlayerState get currentPlayerState => _player.state;
  Duration get currentPosition => _position;
  Duration get currentDuration => _duration;
  int get currentIndex => _currentIndex;

  VibesAudioHandler() {
    _configureAudioSession();
    _player.onPlayerStateChanged.listen(_onPlayerStateChanged);
    _player.onPositionChanged.listen(_onPositionChanged);
    _player.onDurationChanged.listen(_onDurationChanged);
  }

  /// Load the full playlist so next/previous work from the lock screen.
  void loadQueue(List<QueueEntry> entries) {
    _entries = entries;
    queue.add(entries.map((e) => e.item).toList());
  }

  // ── Public playback API used by the carousel UI ──

  Future<void> playAudio({required int index}) async {
    if (index < 0 || index >= _entries.length) return;
    final entry = _entries[index];
    _currentIndex = index;

    // Set lock screen info before stopping so art never goes blank
    mediaItem.add(entry.item);
    _broadcastState(processingState: AudioProcessingState.loading);

    _position = Duration.zero;
    _duration = Duration.zero;

    // Suppress the stopped-state broadcast so lock screen stays intact
    _isSwitchingTrack = true;
    await _player.stop();
    _isSwitchingTrack = false;

    await _player.play(UrlSource(entry.audioUrl));
  }

  // ── BaseAudioHandler overrides (lock screen / notification buttons) ──

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
    _broadcastState(playing: false, processingState: AudioProcessingState.idle);
    _externalStopController.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final next = _currentIndex + 1;
    if (next >= _entries.length) return;
    await playAudio(index: next);
    _skipController.add(next);
  }

  @override
  Future<void> skipToPrevious() async {
    // If more than 3 s in, restart current track instead of going back
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prev = _currentIndex - 1;
    if (prev < 0) return;
    await playAudio(index: prev);
    _skipController.add(prev);
  }

  // ── Internal ──

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

  void _onPlayerStateChanged(PlayerState state) {
    // Ignore the intermediate stopped event that fires during a track switch
    // so the lock screen artwork and metadata stay visible throughout.
    if (_isSwitchingTrack) return;

    final playing = state == PlayerState.playing;
    AudioProcessingState ps;
    if (state == PlayerState.completed) {
      ps = AudioProcessingState.completed;
    } else if (state == PlayerState.stopped) {
      ps = AudioProcessingState.idle;
    } else {
      ps = AudioProcessingState.ready;
    }
    _broadcastState(playing: playing, processingState: ps);
    if (state == PlayerState.completed) mediaItem.add(null);
  }

  void _onPositionChanged(Duration pos) {
    _position = pos;
    _broadcastState(updatePosition: pos);
  }

  void _onDurationChanged(Duration dur) {
    _duration = dur;
    final current = mediaItem.value;
    if (current != null) mediaItem.add(current.copyWith(duration: dur));
  }

  void _broadcastState({
    bool? playing,
    AudioProcessingState? processingState,
    Duration? updatePosition,
  }) {
    final prev = playbackState.value;
    final isPlaying = playing ?? prev.playing;
    playbackState.add(prev.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: processingState ?? prev.processingState,
      playing: isPlaying,
      updatePosition: updatePosition ?? prev.updatePosition,
    ));
  }

  void disposeHandler() {
    _player.dispose();
    _externalStopController.close();
    _skipController.close();
  }
}
