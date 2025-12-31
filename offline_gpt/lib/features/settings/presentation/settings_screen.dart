import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/tech_theme.dart';
import '../../auth/state/auth_controller.dart';
import '../domain/user_settings.dart';
import '../state/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _maxTokensController = TextEditingController();
  bool _syncedController = false;

  @override
  void dispose() {
    _maxTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final settingsState = ref.watch(settingsControllerProvider);

    if (!settingsState.isLoading && !_syncedController) {
      _maxTokensController.text = settingsState.settings.maxTokens.toString();
      _syncedController = true;
    }

    return Scaffold(
      backgroundColor: TechPalette.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Parametres'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const TechBackground(),
          SafeArea(
            child: settingsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      Text(
                        'Profil',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: TechPalette.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: TechPalette.surface,
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(authState.user?.fullName ?? 'Utilisateur'),
                          subtitle: Text(authState.user?.email ?? ''),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Parametres IA',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: TechPalette.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Temperature: ${settingsState.settings.temperature.toStringAsFixed(2)}',
                              ),
                              Slider(
                                value: settingsState.settings.temperature,
                                min: 0.1,
                                max: 1,
                                divisions: 9,
                                activeColor: TechPalette.accent,
                                label: settingsState.settings.temperature
                                    .toStringAsFixed(2),
                                onChanged: (value) {
                                  _updateSettings(
                                    settingsState.settings.copyWith(
                                      temperature: value,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _maxTokensController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max tokens',
                                  helperText: 'Valeur entre 128 et 4096',
                                  prefixIcon: Icon(Icons.memory_outlined),
                                ),
                                onChanged: (value) {
                                  final parsed = int.tryParse(value);
                                  if (parsed == null) {
                                    return;
                                  }
                                  final clamped = parsed.clamp(128, 4096);
                                  _updateSettings(
                                    settingsState.settings.copyWith(
                                      maxTokens: clamped,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Contexte persistant'),
                                value: settingsState.settings.contextEnabled,
                                activeColor: TechPalette.accent,
                                onChanged: (value) {
                                  _updateSettings(
                                    settingsState.settings.copyWith(
                                      contextEnabled: value,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: const Text('Changer mot de passe'),
                          subtitle: const Text('Bientot disponible'),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TechPalette.accent,
                          foregroundColor: TechPalette.background,
                        ),
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (mounted) {
                            context.go('/chat');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Se deconnecter'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _updateSettings(UserSettings settings) {
    ref.read(settingsControllerProvider.notifier).updateSettings(settings);
  }
}
