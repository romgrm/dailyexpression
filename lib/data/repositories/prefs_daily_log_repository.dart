import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/daily_assignment.dart';
import '../../domain/repositories/daily_log_repository.dart';

/// Local [DailyLogRepository] backed by shared_preferences. The whole log is a
/// single JSON array under one key; entries are tiny (one id per day), so this
/// stays cheap even after a year and trivial to sync to a backend later.
class PrefsDailyLogRepository implements DailyLogRepository {
  PrefsDailyLogRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _logKey = 'daily_log';

  @override
  Future<DailyAssignment?> forDay(String dayKey, String pairKey) async {
    for (final entry in _readAll()) {
      if (entry.dayKey == dayKey && entry.pairKey == pairKey) return entry;
    }
    return null;
  }

  @override
  Future<List<DailyAssignment>> history(String pairKey) async {
    final entries = _readAll().where((e) => e.pairKey == pairKey).toList()
      ..sort((a, b) => a.dayKey.compareTo(b.dayKey));
    return entries;
  }

  @override
  Future<void> save(DailyAssignment assignment) async {
    final entries = _readAll()
      ..removeWhere((e) =>
          e.dayKey == assignment.dayKey && e.pairKey == assignment.pairKey)
      ..add(assignment);
    await _prefs.setString(
      _logKey,
      jsonEncode(entries.map(_toJson).toList()),
    );
  }

  List<DailyAssignment> _readAll() {
    final raw = _prefs.getString(_logKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: true);
  }

  static Map<String, dynamic> _toJson(DailyAssignment a) => {
        'dayKey': a.dayKey,
        'pairKey': a.pairKey,
        'conceptId': a.conceptId,
        'assignedAt': a.assignedAt.toIso8601String(),
        'schemaVersion': a.schemaVersion,
      };

  static DailyAssignment _fromJson(Map<String, dynamic> json) => DailyAssignment(
        dayKey: json['dayKey'] as String,
        pairKey: json['pairKey'] as String,
        conceptId: json['conceptId'] as String,
        assignedAt: DateTime.parse(json['assignedAt'] as String),
        schemaVersion: json['schemaVersion'] as int? ?? 1,
      );
}
