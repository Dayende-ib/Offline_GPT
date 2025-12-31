import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../data/model_repository.dart';
import '../domain/model_installation.dart';
import 'models_state.dart';

final modelsControllerProvider =
    StateNotifierProvider<ModelsController, ModelsState>((ref) {
  return ModelsController(ref.watch(modelRepositoryProvider));
});

class ModelsController extends StateNotifier<ModelsState> {
  ModelsController(this._repository) : super(ModelsState.initial()) {
    Future.microtask(loadModels);
  }

  final ModelRepository _repository;
  Future<void> loadModels() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final remoteModels = await _repository.fetchRemoteModels();
      final localStates = await _repository.fetchLocalStates();
      final activeModelId = await _repository.getActiveModelId();

      final models = remoteModels.map((info) {
        final local = localStates[info.id];
        if (local == null) {
          return ModelItem(info: info, status: ModelStatus.notInstalled);
        }
        final status = local.isActive
            ? ModelStatus.active
            : (local.status == 'installed' || local.status == 'active')
                ? ModelStatus.installed
                : ModelStatus.notInstalled;
        return ModelItem(
          info: info,
          status: status,
          localPath: local.localPath,
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        models: models,
        activeModelId: activeModelId,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les modeles',
      );
    }
  }

  Future<void> downloadModel(ModelItem item) async {
    final index = state.models.indexWhere((model) => model.info.id == item.info.id);
    if (index < 0) {
      return;
    }

    state = state.copyWith(errorMessage: null);
    _updateModel(index, item.copyWith(status: ModelStatus.downloading, progress: 0));

    for (var step = 1; step <= 10; step++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _updateModel(
        index,
        state.models[index].copyWith(
          progress: step / 10,
          status: ModelStatus.downloading,
        ),
      );
    }

    try {
      final localPath = await _writeMockModelFile(item.info.id);
      final shaMatches = await _verifySha(localPath, item.info.sha256);
      if (!shaMatches) {
        _updateModel(index, item.copyWith(status: ModelStatus.notInstalled));
        state = state.copyWith(errorMessage: 'Verification SHA256 impossible');
        return;
      }

      await _repository.saveInstalledModel(
        modelId: item.info.id,
        localPath: localPath,
      );

      _updateModel(
        index,
        item.copyWith(
          status: ModelStatus.installed,
          progress: 1,
          localPath: localPath,
        ),
      );
    } catch (_) {
      _updateModel(index, item.copyWith(status: ModelStatus.notInstalled));
      state = state.copyWith(errorMessage: 'Echec du telechargement');
    }
  }

  Future<void> activateModel(ModelItem item) async {
    if (!item.isInstalled) {
      return;
    }
    await _repository.setActiveModel(item.info.id);

    final updated = state.models.map((model) {
      if (model.info.id == item.info.id) {
        return model.copyWith(status: ModelStatus.active);
      }
      if (model.status == ModelStatus.active) {
        return model.copyWith(status: ModelStatus.installed);
      }
      return model;
    }).toList();

    state = state.copyWith(models: updated, activeModelId: item.info.id);
  }

  void _updateModel(int index, ModelItem item) {
    final models = List<ModelItem>.from(state.models);
    models[index] = item;
    state = state.copyWith(models: models);
  }

  Future<String> _writeMockModelFile(String modelId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, 'models', '$modelId.bin');
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString('offlinegpt-model-$modelId-v1');
    return file.path;
  }

  Future<bool> _verifySha(String filePath, String expectedSha) async {
    final file = File(filePath);
    final digest = sha256.convert(await file.readAsBytes()).toString();
    return digest == expectedSha;
  }

}
