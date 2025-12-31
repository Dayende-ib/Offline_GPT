import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../domain/user_settings.dart';
import 'settings_state.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._repository) : super(SettingsState.initial()) {
    Future.microtask(load);
  }

  final SettingsRepository _repository;

  Future<void> load() async {
    try {
      final settings = await _repository.load();
      state = state.copyWith(isLoading: false, settings: settings);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur chargement');
    }
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = state.copyWith(settings: settings);
    await _repository.save(settings);
  }
}
