import 'dart:async';
import 'dart:io';

class ModelManager {
  final Directory modelDirectory;

  ModelManager({required this.modelDirectory});

  static const defaultModelFileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';
  static const defaultModelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf';
  static const defaultModelSizeBytes = 987000000;

  static ModelManager get default_ =>
      ModelManager(modelDirectory: _defaultModelDirectory());

  static Directory _defaultModelDirectory() {
    if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'];
      if (home != null) {
        return Directory('$home\\.mindora\\models');
      }
    }
    final home = Platform.environment['HOME'];
    if (home != null) {
      return Directory('$home/.mindora/models');
    }
    return Directory('mindora_models');
  }

  Future<bool> isModelDownloaded() async {
    if (!await modelDirectory.exists()) return false;
    await _cleanupPartialFiles();
    final files = await modelDirectory.list().toList();
    for (final f in files) {
      if (!f.path.endsWith('.gguf')) continue;
      try {
        final stat = await f.stat();
        if (stat.size > 0) return true;
      } catch (_) {}
    }
    return false;
  }

  Future<String?> getModelPath() async {
    if (!await modelDirectory.exists()) return null;
    await _cleanupPartialFiles();
    final files = await modelDirectory.list().toList();
    final ggufFiles = files.where((f) => f.path.endsWith('.gguf')).toList();
    if (ggufFiles.isEmpty) return null;
    return ggufFiles.first.path;
  }

  Future<void> _cleanupPartialFiles() async {
    if (!await modelDirectory.exists()) return;
    final files = await modelDirectory.list().toList();
    for (final file in files) {
      if (file.path.endsWith('.part')) {
        await file.delete();
      }
    }
  }

  Future<String> downloadModel({
    required void Function(double progress) onProgress,
    String? url,
  }) async {
    final downloadUrl = url ?? defaultModelUrl;
    final fileName = downloadUrl.split('/').last;
    final targetFile = File('${modelDirectory.path}/$fileName');
    final tempFile = File('${modelDirectory.path}/$fileName.part');

    if (await targetFile.exists()) {
      final stat = await targetFile.stat();
      if (stat.size >= defaultModelSizeBytes * 0.9) {
        return targetFile.path;
      }
      await targetFile.delete();
    }

    if (!await modelDirectory.exists()) {
      await modelDirectory.create(recursive: true);
    }

    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to download model: HTTP ${response.statusCode}',
          uri: Uri.parse(downloadUrl),
        );
      }

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();

      if (totalBytes > 0 && receivedBytes != totalBytes) {
        await tempFile.delete();
        throw HttpException(
          'Download incomplete: received $receivedBytes of $totalBytes bytes',
          uri: Uri.parse(downloadUrl),
        );
      }

      final tempStat = await tempFile.stat();
      if (tempStat.size < 1024) {
        await tempFile.delete();
        throw HttpException(
          'Downloaded model file is too small: ${tempStat.size} bytes',
          uri: Uri.parse(downloadUrl),
        );
      }

      await tempFile.rename(targetFile.path);
      return targetFile.path;
    } finally {
      client.close();
    }
  }

  Future<void> deleteModel() async {
    if (!await modelDirectory.exists()) return;
    final files = await modelDirectory.list().toList();
    for (final file in files) {
      if (file.path.endsWith('.gguf') || file.path.endsWith('.part')) {
        await file.delete();
      }
    }
  }

  Future<int> getModelSize() async {
    final path = await getModelPath();
    if (path == null) return 0;
    final file = File(path);
    if (!await file.exists()) return 0;
    final stat = await file.stat();
    return stat.size;
  }
}
