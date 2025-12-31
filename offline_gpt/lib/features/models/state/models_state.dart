import '../domain/model_installation.dart';

class ModelsState {
  final bool isLoading;
  final List<ModelItem> models;
  final String? activeModelId;
  final String? errorMessage;

  ModelsState({
    required this.isLoading,
    required this.models,
    this.activeModelId,
    this.errorMessage,
  });

  ModelsState copyWith({
    bool? isLoading,
    List<ModelItem>? models,
    String? activeModelId,
    String? errorMessage,
  }) {
    return ModelsState(
      isLoading: isLoading ?? this.isLoading,
      models: models ?? this.models,
      activeModelId: activeModelId ?? this.activeModelId,
      errorMessage: errorMessage,
    );
  }

  factory ModelsState.initial() => ModelsState(isLoading: true, models: []);
}
