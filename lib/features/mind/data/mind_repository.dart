import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seima/core/errors/app_exception.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/data/id_provider.dart';

class MindRepository {
  static const _mindsKey = 'minds';
  static const _backupMindsKey = 'minds_backup';

  Future<List<Mind>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_mindsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => _safeFromJson(e as Map<String, dynamic>))
          .where((m) => m != null)
          .cast<Mind>()
          .toList();
    } catch (_) {
      final backup = prefs.getString(_backupMindsKey);
      if (backup == null || backup.isEmpty) {
        throw AppException(
          message: 'Mind data corrupted and no backup available.',
        );
      }
      try {
        final list = jsonDecode(backup) as List<dynamic>;
        final minds = list
            .map((e) => _safeFromJson(e as Map<String, dynamic>))
            .where((m) => m != null)
            .cast<Mind>()
            .toList();
        await prefs.setString(_mindsKey, backup);
        return minds;
      } catch (_) {
        throw AppException(
          message: 'Mind data corrupted and backup restoration failed.',
        );
      }
    }
  }

  Mind? _safeFromJson(Map<String, dynamic> json) {
    try {
      return Mind.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<Mind?> load(String id) async {
    try {
      final minds = await loadAll();
      return minds.cast<Mind?>().firstWhere(
        (m) => m!.id == id,
        orElse: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Mind mind) async {
    final prefs = await SharedPreferences.getInstance();
    final currentJson = prefs.getString(_mindsKey);
    List<Mind> minds;
    try {
      if (currentJson != null && currentJson.isNotEmpty) {
        final list = jsonDecode(currentJson) as List<dynamic>;
        minds = list
            .map((e) => _safeFromJson(e as Map<String, dynamic>))
            .where((m) => m != null)
            .cast<Mind>()
            .toList();
      } else {
        minds = [];
      }
    } catch (_) {
      minds = [];
    }

    final index = minds.indexWhere((m) => m.id == mind.id);
    if (index >= 0) {
      final existing = minds[index];
      if (mind.sequenceNumber < existing.sequenceNumber) {
        return;
      }
      minds[index] = mind;
    } else {
      minds.add(mind);
    }

    final serialized = jsonEncode(minds.map((m) => m.toJson()).toList());
    try {
      await prefs.setString(_backupMindsKey, currentJson ?? '[]');
      await prefs.setString(_mindsKey, serialized);
    } catch (e) {
      try {
        if (currentJson != null) {
          await prefs.setString(_mindsKey, currentJson);
        }
      } catch (_) {}
      throw AppException(message: 'Failed to save mind', originalError: e);
    }
  }

  Future<void> delete(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final minds = await loadAll();
      minds.removeWhere((m) => m.id == id);
      final currentJson = prefs.getString(_mindsKey);
      final serialized = jsonEncode(minds.map((m) => m.toJson()).toList());
      await prefs.setString(_backupMindsKey, currentJson ?? '[]');
      await prefs.setString(_mindsKey, serialized);
    } catch (e) {
      throw AppException(message: 'Failed to delete mind', originalError: e);
    }
  }

  Future<Mind> duplicate(String id) async {
    try {
      final minds = await loadAll();
      final original = minds.firstWhere((m) => m.id == id);
      final copy = Mind(
        id: generateId(),
        title: '${original.title} (Copy)',
        description: original.description,
        nodes: original.nodes
            .map((n) => n.copyWith(id: generateId(), updatedAt: DateTime.now()))
            .toList(),
        connections: original.connections
            .map((c) => c.copyWith(id: generateId()))
            .toList(),
      );
      await save(copy);
      return copy;
    } catch (e) {
      throw AppException(message: 'Failed to duplicate mind', originalError: e);
    }
  }

  Future<void> updateLastAccessed(String id) async {
    final mind = await load(id);
    if (mind != null) {
      await save(mind.copyWith(lastAccessedAt: DateTime.now()));
    }
  }
}
