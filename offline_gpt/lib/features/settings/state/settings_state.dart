import '../domain/user_settings.dart';

class SettingsState {
  final bool isLoading;
  final UserSettings settings;
  final String? errorMessage;

  SettingsState({
    required this.isLoading,
    required this.settings,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    UserSettings? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  factory SettingsState.initial() => SettingsState(
        isLoading: true,
        settings: UserSettings(temperature: 0.7, maxTokens: 512, contextEnabled: true),
      );
}
