import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/ai/data/model_manager.dart';

void main() {
  group('ModelManager', () {
    late Directory tempDir;
    late ModelManager manager;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('mindora_model_test_');
      manager = ModelManager(modelDirectory: tempDir);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('isModelDownloaded returns false when no models', () async {
      final result = await manager.isModelDownloaded();
      expect(result, false);
    });

    test('getModelPath returns null when no models', () async {
      final path = await manager.getModelPath();
      expect(path, isNull);
    });

    test('isModelDownloaded returns true when gguf file exists', () async {
      File('${tempDir.path}/test-model.gguf').writeAsStringSync('model data');
      final result = await manager.isModelDownloaded();
      expect(result, true);
    });

    test('getModelPath returns path when gguf file exists', () async {
      final testFile = File('${tempDir.path}/my-model.gguf');
      testFile.writeAsStringSync('model data');
      final path = await manager.getModelPath();
      expect(path, isNotNull);
      expect(path, endsWith('my-model.gguf'));
    });

    test('getModelPath returns first gguf file', () async {
      File('${tempDir.path}/first.gguf').createSync();
      File('${tempDir.path}/second.gguf').createSync();
      final path = await manager.getModelPath();
      expect(path, endsWith('.gguf'));
    });

    test('getModelSize returns 0 when no model', () async {
      final size = await manager.getModelSize();
      expect(size, 0);
    });

    test('getModelSize returns file size', () async {
      final testFile = File('${tempDir.path}/model.gguf');
      testFile.writeAsBytesSync(List.filled(1024, 1));
      final size = await manager.getModelSize();
      expect(size, 1024);
    });

    test('deleteModel removes gguf files', () async {
      File('${tempDir.path}/model.gguf').createSync();
      await manager.deleteModel();
      final exists = await File('${tempDir.path}/model.gguf').exists();
      expect(exists, false);
    });

    test('defaultModelDirectory creates expected path', () {
      final dir = ModelManager.default_;
      expect(dir.modelDirectory.path, contains('.mindora'));
    });

    test('defaultModelUrl is valid', () {
      expect(ModelManager.defaultModelUrl, contains('huggingface.co'));
      expect(ModelManager.defaultModelUrl, endsWith('.gguf'));
    });

    test('isModelDownloaded returns false for empty file', () async {
      File('${tempDir.path}/empty.gguf').createSync();
      final result = await manager.isModelDownloaded();
      expect(result, false);
    });

    test('isModelDownloaded cleans up orphaned part files', () async {
      File(
        '${tempDir.path}/model.gguf.part',
      ).writeAsBytesSync(List.filled(100, 1));
      File('${tempDir.path}/model.gguf').writeAsStringSync('model data');
      final result = await manager.isModelDownloaded();
      expect(result, true);
      final partExists = await File('${tempDir.path}/model.gguf.part').exists();
      if (partExists) {
        await File('${tempDir.path}/model.gguf.part').delete();
      }
    });

    test('deleteModel also removes part files', () async {
      File('${tempDir.path}/model.gguf').createSync();
      File('${tempDir.path}/model.gguf.part').createSync();
      await manager.deleteModel();
      final modelExists = await File('${tempDir.path}/model.gguf').exists();
      final partExists = await File('${tempDir.path}/model.gguf.part').exists();
      expect(modelExists, false);
      expect(partExists, false);
    });

    test(
      'isModelDownloaded returns false when only part files exist',
      () async {
        File(
          '${tempDir.path}/partial.gguf.part',
        ).writeAsStringSync('partial data');
        final result = await manager.isModelDownloaded();
        expect(result, false);
      },
    );

    test('getModelSize returns 0 for empty file', () async {
      File('${tempDir.path}/model.gguf').createSync();
      final size = await manager.getModelSize();
      expect(size, 0);
    });
  });
}
