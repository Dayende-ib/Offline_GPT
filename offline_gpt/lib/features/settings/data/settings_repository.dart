import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/settings_storage.dart';
import '../domain/user_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(storage: SettingsStorage());
});

class SettingsRepository {
  SettingsRepository({required this.storage});

  final SettingsStorage storage;

  Future<UserSettings> load() async {
    final temperature = await storage.getTemperature();
    final maxTokens = await storage.getMaxTokens();
    final contextEnabled = await storage.getContextEnabled();
    return UserSettings(
      temperature: temperature,
      maxTokens: maxTokens,
      contextEnabled: contextEnabled,
    );
  }

  Future<void> save(UserSettings settings) async {
    await storage.saveTemperature(settings.temperature);
    await storage.saveMaxTokens(settings.maxTokens);
    await storage.saveContextEnabled(settings.contextEnabled);
  }
}
