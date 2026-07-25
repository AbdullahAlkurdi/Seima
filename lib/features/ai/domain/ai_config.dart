class AIConfig {
  final String? modelPath;
  final String? llamaExecutablePath;
  final bool useLLM;
  final int maxContextTokens;
  final double temperature;

  const AIConfig({
    this.modelPath,
    this.llamaExecutablePath,
    this.useLLM = false,
    this.maxContextTokens = 4096,
    this.temperature = 0.7,
  });

  bool get hasModelPath => modelPath != null && modelPath!.isNotEmpty;
}
