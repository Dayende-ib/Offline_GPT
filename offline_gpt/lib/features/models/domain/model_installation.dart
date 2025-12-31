import 'model_info.dart';

enum ModelStatus { notInstalled, downloading, installed, active }

class ModelItem {
  final ModelInfo info;
  final ModelStatus status;
  final double progress;
  final String? localPath;

  ModelItem({
    required this.info,
    required this.status,
    this.progress = 0,
    this.localPath,
  });

  bool get isInstalled => status == ModelStatus.installed || status == ModelStatus.active;
  bool get isActive => status == ModelStatus.active;

  ModelItem copyWith({
    ModelStatus? status,
    double? progress,
    String? localPath,
  }) {
    return ModelItem(
      info: info,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
    );
  }
}
