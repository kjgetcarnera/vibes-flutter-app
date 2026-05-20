class VibeCheckResult {
  const VibeCheckResult({
    required this.sessionId,
    required this.brainReadinessScore,
    required this.brainState,
    required this.brainStateSubtitle,
    required this.brainStateDescription,
    required this.brainReadinessRecommendation,
    required this.frequencyScore,
    required this.frequencyLabel,
    required this.frequencyHz,
    required this.frequencyTag,
    required this.frequencyMeaning,
    required this.frequencyCta,
    required this.frequencyRecommendation,
  });

  // Session anchor — stored so the post-session call can reference it
  final String sessionId;

  // Brain Readiness (BRS)
  final double brainReadinessScore;
  final String brainState;
  final String brainStateSubtitle;   // note field
  final String brainStateDescription; // meaning field
  final String brainReadinessRecommendation;

  // Brain Frequency (BFS)
  final double frequencyScore;       // bfs
  final String frequencyLabel;       // state (e.g. "Focused")
  final double frequencyHz;          // hz
  final String frequencyTag;         // tag (e.g. "alpha")
  final String frequencyMeaning;     // meaning
  final String frequencyCta;         // activity_suggestion
  final String frequencyRecommendation;

  factory VibeCheckResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final scores = data['scores'] as Map<String, dynamic>;

    final brs = scores['brain_readiness'] as Map<String, dynamic>;
    final bfs = scores['brain_frequency'] as Map<String, dynamic>;

    return VibeCheckResult(
      sessionId: data['session_id'] as String? ?? '',
      brainReadinessScore: (brs['brs'] as num).toDouble(),
      brainState: brs['state'] as String? ?? '',
      brainStateSubtitle: brs['note'] as String? ??
          brs['recommendation'] as String? ?? '',
      brainStateDescription: brs['meaning'] as String? ?? '',
      brainReadinessRecommendation: brs['recommendation'] as String? ?? '',
      frequencyScore: (bfs['bfs'] as num).toDouble(),
      frequencyLabel: bfs['state'] as String? ?? '',
      frequencyHz: (bfs['hz'] as num).toDouble(),
      frequencyTag: bfs['tag'] as String? ?? '',
      frequencyMeaning: bfs['meaning'] as String? ?? '',
      frequencyCta: bfs['activity_suggestion'] as String? ?? '',
      frequencyRecommendation: bfs['recommendation'] as String? ?? '',
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
        frequencyScore: 48.0,
        frequencyLabel: 'Recovering',
        frequencyHz: 198,
        frequencyTag: 'beta',
        frequencyMeaning: 'Elevated mental activity with some tension.',
        frequencyCta: 'Let\'s build momentum',
        frequencyRecommendation: 'Try a grounding exercise first.',
      );
}
