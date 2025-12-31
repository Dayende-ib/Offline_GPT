import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/tech_theme.dart';
import '../domain/model_installation.dart';
import '../state/models_controller.dart';

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modelsControllerProvider);

    return Scaffold(
      backgroundColor: TechPalette.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Modeles disponibles'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const TechBackground(),
          SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    color: TechPalette.accent,
                    onRefresh: () =>
                        ref.read(modelsControllerProvider.notifier).loadModels(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(color: TechPalette.error),
                            ),
                          ),
                        ...state.models.map((model) => _ModelCard(model: model)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends ConsumerWidget {
  final ModelItem model;

  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(modelsControllerProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    model.info.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (model.info.id == 'lite')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [TechPalette.accent, TechPalette.accentAlt],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Recommande',
                      style: TextStyle(color: TechPalette.background),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(model.info.description),
            const SizedBox(height: 8),
            Text('Taille: ${model.info.sizeMB} MB'),
            if (model.info.recommendedFor.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Pour: ${model.info.recommendedFor.join(', ')}'),
            ],
            const SizedBox(height: 12),
            if (model.status == ModelStatus.downloading)
              LinearProgressIndicator(
                value: model.progress,
                color: TechPalette.accent,
                backgroundColor: TechPalette.surface,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusPill(status: model.status),
                const Spacer(),
                if (model.status == ModelStatus.notInstalled)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TechPalette.accent,
                      foregroundColor: TechPalette.background,
                    ),
                    onPressed: () => notifier.downloadModel(model),
                    child: const Text('Telecharger'),
                  ),
                if (model.status == ModelStatus.installed)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TechPalette.accent,
                      side: const BorderSide(color: TechPalette.accent),
                    ),
                    onPressed: () => notifier.activateModel(model),
                    child: const Text('Activer'),
                  ),
                if (model.status == ModelStatus.active)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: TechPalette.accentAlt,
                      foregroundColor: TechPalette.background,
                    ),
                    onPressed: null,
                    child: const Text('Actif'),
                  ),
                if (model.status == ModelStatus.downloading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Telechargement...'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ModelStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (status) {
      case ModelStatus.active:
        label = 'Actif';
        break;
      case ModelStatus.installed:
        label = 'Installe';
        break;
      case ModelStatus.downloading:
        label = 'Telechargement';
        break;
      case ModelStatus.notInstalled:
        label = 'Non installe';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TechPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TechPalette.outline),
      ),
      child: Text(label),
    );
  }
}
