class UserSettings {
  final double temperature;
  final int maxTokens;
  final bool contextEnabled;

  UserSettings({
    required this.temperature,
    required this.maxTokens,
    required this.contextEnabled,
  });

  UserSettings copyWith({
    double? temperature,
    int? maxTokens,
    bool? contextEnabled,
  }) {
    return UserSettings(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      contextEnabled: contextEnabled ?? this.contextEnabled,
    );
  }
}
