class ModelInfo {
  final String modelName;
  final String modelPath;
  final int modelSizeBytes;
  final int contextLength;
  final bool isLoaded;
  final String? runtimeVersion;

  const ModelInfo({
    required this.modelName,
    required this.modelPath,
    required this.modelSizeBytes,
    this.contextLength = 4096,
    this.isLoaded = false,
    this.runtimeVersion,
  });
}
