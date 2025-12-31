class ModelInfo {
  final String id;
  final String name;
  final int sizeMB;
  final String description;
  final List<String> recommendedFor;
  final String sha256;
  final String downloadUrl;

  ModelInfo({
    required this.id,
    required this.name,
    required this.sizeMB,
    required this.description,
    required this.recommendedFor,
    required this.sha256,
    required this.downloadUrl,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sizeMB: (json['sizeMB'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      recommendedFor: (json['recommendedFor'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      sha256: json['sha256']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
    );
  }
}
