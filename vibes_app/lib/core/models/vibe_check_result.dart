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
      brainStateSubtitle: brs['note'] as String? ??
          brs['recommendation'] as String? ?? '',
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
    );
  }

  static VibeCheckResult mock() => const VibeCheckResult(
        sessionId: 'mock-session-id',
        brainReadinessScore: 87.3,
        brainState: 'Over-Activated',
        brainStateSubtitle: 'Pay attention',
        brainStateDescription:
            'Your nervous system is wired. High arousal signals. Elevated stress markers. That full day? You\'re still carrying it.',
        brainReadinessRecommendation: 'Take a short break before your session.',
        brainReadinessColors: ['#FFA500'],
        frequencyScore: 48.0,
        frequencyLabel: 'Recovering',
        frequencyHz: 198,
        frequencyTag: 'beta',
        frequencyMeaning: 'Elevated mental activity with some tension.',
        frequencyCta: 'Let\'s build momentum',
        frequencyRecommendation: 'Try a grounding exercise first.',
        frequencyColors: ['#4A90D9', '#7EC8E3'],
        frequencyBandMin: 183,
        frequencyBandMax: 213,
      );
}
