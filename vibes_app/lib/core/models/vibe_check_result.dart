class VibeCheckResult {
  const VibeCheckResult({
    required this.brainReadinessScore,
    required this.brainState,
    required this.brainStateSubtitle,
    required this.brainStateDescription,
    required this.frequencyScore,
    required this.frequencyLabel,
    required this.frequencyHz,
    required this.frequencyBandMin,
    required this.frequencyBandMax,
    required this.vibingWithYouCount,
    required this.vibingActiveInBand,
    required this.frequencyCta,
  });

  final double brainReadinessScore;
  final String brainState;
  final String brainStateSubtitle;
  final String brainStateDescription;

  final int frequencyScore;
  final String frequencyLabel;
  final double frequencyHz;
  final double frequencyBandMin;
  final double frequencyBandMax;
  final int vibingWithYouCount;
  final int vibingActiveInBand;
  final String frequencyCta;

  factory VibeCheckResult.fromJson(Map<String, dynamic> json) {
    return VibeCheckResult(
      brainReadinessScore: (json['brain_readiness_score'] as num).toDouble(),
      brainState: json['brain_state'] as String,
      brainStateSubtitle: json['brain_state_subtitle'] as String,
      brainStateDescription: json['brain_state_description'] as String,
      frequencyScore: json['frequency_score'] as int,
      frequencyLabel: json['frequency_label'] as String,
      frequencyHz: (json['frequency_hz'] as num).toDouble(),
      frequencyBandMin: (json['frequency_band_min'] as num).toDouble(),
      frequencyBandMax: (json['frequency_band_max'] as num).toDouble(),
      vibingWithYouCount: json['vibing_with_you_count'] as int,
      vibingActiveInBand: json['vibing_active_in_band'] as int,
      frequencyCta: json['frequency_cta'] as String,
    );
  }

  // Mock result used until the real API is live
  static VibeCheckResult mock() => const VibeCheckResult(
        brainReadinessScore: 87.3,
        brainState: 'Over-Activated',
        brainStateSubtitle: 'Pay attention',
        brainStateDescription:
            'Your nervous system is wired. High arousal signals. Elevated stress markers. That full day? You\'re still carrying it.',
        frequencyScore: 48,
        frequencyLabel: 'Recovering',
        frequencyHz: 198,
        frequencyBandMin: 183,
        frequencyBandMax: 213,
        vibingWithYouCount: 8,
        vibingActiveInBand: 72,
        frequencyCta: 'Let\'s build momentum',
      );
}
