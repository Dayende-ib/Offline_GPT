import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_client.dart';
import '../../../core/storage/app_database.dart';
import '../domain/model_info.dart';

final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepository(
    dio: ref.watch(plainDioProvider),
    database: AppDatabase.instance,
  );
});

class LocalModelState {
  final String modelId;
  final String status;
  final String? localPath;
  final bool isActive;

  LocalModelState({
    required this.modelId,
    required this.status,
    this.localPath,
    required this.isActive,
  });
}

class ModelRepository {
  ModelRepository({required this.dio, required this.database});

  final Dio dio;
  final AppDatabase database;

  Future<List<ModelInfo>> fetchRemoteModels() async {
    final response = await dio.get('/models');
    final list = (response.data as List<dynamic>?) ?? [];
    return list
        .map((item) => ModelInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, LocalModelState>> fetchLocalStates() async {
    final rows = await database.fetchModels();
    return {
      for (final row in rows)
        row['modelId'] as String: LocalModelState(
          modelId: row['modelId'] as String,
          status: row['status'] as String,
          localPath: row['localPath'] as String?,
          isActive: (row['isActive'] as int?) == 1,
        ),
    };
  }

  Future<void> saveInstalledModel({
    required String modelId,
    required String localPath,
  }) async {
    await database.upsertModel({
      'modelId': modelId,
      'status': 'installed',
      'localPath': localPath,
      'isActive': 0,
    });
  }

  Future<void> setActiveModel(String modelId) async {
    await database.setActiveModel(modelId);
  }

  Future<String?> getActiveModelId() async {
    final rows = await database.fetchModels();
    for (final row in rows) {
      if ((row['isActive'] as int?) == 1) {
        return row['modelId'] as String;
      }
    }
    return null;
  }
}
