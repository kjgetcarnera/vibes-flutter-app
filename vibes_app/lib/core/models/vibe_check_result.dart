class RecommendedAudio {
  const RecommendedAudio({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.coverImageUrl,
    required this.audioUrl,
  });

  final int id;
  final String name;
  final String subtitle;
  final String coverImageUrl;
  final String audioUrl;

  factory RecommendedAudio.fromJson(Map<String, dynamic> json) {
    return RecommendedAudio(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      audioUrl: json['audio_url'] as String? ?? '',
    );
  }
}

class VibeCheckResult {
  const VibeCheckResult({
    required this.sessionId,
    required this.brainReadinessScore,
    required this.brainState,
    required this.brainStateSubtitle,
    required this.brainStateDescription,
    required this.brainReadinessRecommendation,
    required this.brainReadinessColors,
    required this.frequencyScore,
    required this.frequencyLabel,
    required this.frequencyHz,
    required this.frequencyTag,
    required this.frequencyMeaning,
    required this.frequencyCta,
    required this.frequencyRecommendation,
    required this.frequencyColors,
    required this.frequencyBandMin,
    required this.frequencyBandMax,
    this.recommendedAudios = const [],
  });

  final String sessionId;

  // Brain Readiness (BRS)
  final double brainReadinessScore;
  final String brainState;
  final String brainStateSubtitle;
  final String brainStateDescription;
  final String brainReadinessRecommendation;
  final List<String> brainReadinessColors; // hex strings e.g. ["#4CAF50"]

  // Brain Frequency (BFS)
  final double frequencyScore;
  final String frequencyLabel;
  final double frequencyHz;
  final String frequencyTag;
  final String frequencyMeaning;
  final String frequencyCta;
  final String frequencyRecommendation;
  final List<String> frequencyColors; // hex strings e.g. ["#4A90D9","#7EC8E3"]
  final double frequencyBandMin;
  final double frequencyBandMax;
  final List<RecommendedAudio> recommendedAudios;

  factory VibeCheckResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final scores = data['scores'] as Map<String, dynamic>;

    final brs = scores['brain_readiness'] as Map<String, dynamic>;
    final bfs = scores['brain_frequency'] as Map<String, dynamic>;

    List<String> parseColors(Map<String, dynamic> map) {
      final raw = map['colors'];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    return VibeCheckResult(
      sessionId: data['session_id'] as String? ?? '',
      brainReadinessScore: (brs['brs'] as num).toDouble(),
      brainState: brs['state'] as String? ?? '',
      brainStateSubtitle:
          brs['note'] as String? ?? brs['recommendation'] as String? ?? '',
      brainStateDescription: brs['meaning'] as String? ?? '',
      brainReadinessRecommendation: brs['recommendation'] as String? ?? '',
      brainReadinessColors: parseColors(brs),
      frequencyScore: (bfs['bfs'] as num).toDouble(),
      frequencyLabel: bfs['state'] as String? ?? '',
      frequencyHz: (bfs['hz'] as num).toDouble(),
      frequencyTag: bfs['tag'] as String? ?? '',
      frequencyMeaning: bfs['meaning'] as String? ?? '',
      frequencyCta: bfs['activity_suggestion'] as String? ?? '',
      frequencyRecommendation: bfs['recommendation'] as String? ?? '',
      frequencyColors: parseColors(bfs),
      frequencyBandMin: (bfs['band_min'] as num?)?.toDouble() ?? 0,
      frequencyBandMax: (bfs['band_max'] as num?)?.toDouble() ?? 0,
      recommendedAudios: (data['recommended_audios'] as List<dynamic>? ?? [])
          .map((e) => RecommendedAudio.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Returns `other` with this result's recommendedAudios injected.
  VibeCheckResult copyWithResult(VibeCheckResult other) => VibeCheckResult(
    sessionId: other.sessionId,
    brainReadinessScore: other.brainReadinessScore,
    brainState: other.brainState,
    brainStateSubtitle: other.brainStateSubtitle,
    brainStateDescription: other.brainStateDescription,
    brainReadinessRecommendation: other.brainReadinessRecommendation,
    brainReadinessColors: other.brainReadinessColors,
    frequencyScore: other.frequencyScore,
    frequencyLabel: other.frequencyLabel,
    frequencyHz: other.frequencyHz,
    frequencyTag: other.frequencyTag,
    frequencyMeaning: other.frequencyMeaning,
    frequencyCta: other.frequencyCta,
    frequencyRecommendation: other.frequencyRecommendation,
    frequencyColors: other.frequencyColors,
    frequencyBandMin: other.frequencyBandMin,
    frequencyBandMax: other.frequencyBandMax,
    recommendedAudios: recommendedAudios,
  );

  static VibeCheckResult mock() => VibeCheckResult(
    sessionId: 'mock-session-id',
    brainReadinessScore: 87.3,
    brainState: 'Over-Activated',
    brainStateSubtitle: 'Pay attention',
    brainStateDescription:
        'Your nervous system is wired. High arousal signals. Elevated stress markers. That full day? You\'re still carrying it.',
    brainReadinessRecommendation: 'Take a short break before your session.',
    brainReadinessColors: const ['#FFA500'],
    frequencyScore: 48.0,
    frequencyLabel: 'Recovering',
    frequencyHz: 198,
    frequencyTag: 'beta',
    frequencyMeaning: 'Elevated mental activity with some tension.',
    frequencyCta: 'Let\'s build momentum',
    frequencyRecommendation: 'Try a grounding exercise first.',
    frequencyColors: const ['#4A90D9', '#7EC8E3'],
    frequencyBandMin: 183,
    frequencyBandMax: 213,
    recommendedAudios: const [
      RecommendedAudio(
        id: 1,
        name: 'Ambient Serenity',
        subtitle: 'Calming soundscape for meditation',
        coverImageUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      RecommendedAudio(
        id: 2,
        name: 'Forest Rain',
        subtitle: 'Nature sounds for relaxation',
        coverImageUrl:
            'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=400&q=80',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
      RecommendedAudio(
        id: 3,
        name: 'Deep Focus Flow',
        subtitle: 'Binaural beats for concentration',
        coverImageUrl:
            'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&q=80',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      ),
      RecommendedAudio(
        id: 4,
        name: 'Ocean Waves',
        subtitle: 'Soothing coastal ambience',
        coverImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      ),
      RecommendedAudio(
        id: 5,
        name: 'Neural Nurture',
        subtitle: 'Steady support for long focus',
        coverImageUrl:
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      ),
    ],
  );
}
