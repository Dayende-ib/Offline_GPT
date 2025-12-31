import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../core/network/http_client.dart';
import '../data/model_repository.dart';
import '../domain/model_installation.dart';
import '../domain/model_info.dart';
import 'models_state.dart';

final modelsControllerProvider =
    StateNotifierProvider<ModelsController, ModelsState>((ref) {
  return ModelsController(
    ref.watch(modelRepositoryProvider),
    ref.watch(plainDioProvider),
  );
});

class ModelsController extends StateNotifier<ModelsState> {
  ModelsController(this._repository, this._dio) : super(ModelsState.initial()) {
    Future.microtask(loadModels);
  }

  final ModelRepository _repository;
  final Dio _dio;
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
    final index =
        state.models.indexWhere((model) => model.info.id == item.info.id);
    if (index < 0) {
      return;
    }

    state = state.copyWith(errorMessage: null);
    _updateModel(
      index,
      item.copyWith(status: ModelStatus.downloading, progress: 0),
    );

    try {
      if (item.info.downloadUrl.isEmpty) {
        throw Exception('URL manquante');
      }

      final localPath = await _downloadModelFile(item.info);
      final expectedSha = item.info.sha256.trim();
      if (_isValidSha(expectedSha)) {
        final digest = await _sha256File(File(localPath));
        if (digest.toLowerCase() != expectedSha.toLowerCase()) {
          await File(localPath).delete().catchError((_) {});
          _updateModel(index, item.copyWith(status: ModelStatus.notInstalled));
          state = state.copyWith(errorMessage: 'SHA256 invalide');
          return;
        }
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

  Future<String> _downloadModelFile(ModelInfo info) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _resolveFileName(info);
    final filePath = path.join(directory.path, 'models', fileName);
    final file = File(filePath);
    await file.parent.create(recursive: true);

    await _dio.download(
      info.downloadUrl,
      file.path,
      deleteOnError: true,
      onReceiveProgress: (received, total) {
        if (total <= 0) {
          return;
        }
        final progress = received / total;
        _updateProgress(info.id, progress);
      },
    );

    return file.path;
  }

  void _updateProgress(String modelId, double progress) {
    final index = state.models.indexWhere((model) => model.info.id == modelId);
    if (index < 0) {
      return;
    }
    final model = state.models[index];
    _updateModel(
      index,
      model.copyWith(status: ModelStatus.downloading, progress: progress),
    );
  }

  String _resolveFileName(ModelInfo info) {
    final uri = Uri.tryParse(info.downloadUrl);
    final nameFromUrl = uri == null ? '' : path.basename(uri.path);
    if (nameFromUrl.isNotEmpty) {
      return nameFromUrl;
    }
    return '${info.id}.gguf';
  }

  bool _isValidSha(String value) {
    final normalized = value.toLowerCase();
    final shaRegex = RegExp(r'^[a-f0-9]{64}$');
    return shaRegex.hasMatch(normalized);
  }

  Future<String> _sha256File(File file) async {
    final output = AccumulatorSink<Digest>();
    final input = sha256.startChunkedConversion(output);
    await for (final chunk in file.openRead()) {
      input.add(chunk);
    }
    input.close();
    return output.events.single.toString();
  }
}
