import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/streak_state.dart';
import '../../domain/repositories/streak_repository.dart';

/// Local [StreakRepository] backed by shared_preferences. The whole streak is a
/// single tiny JSON object under one key, trivial to sync to a backend later.
class PrefsStreakRepository implements StreakRepository {
  PrefsStreakRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'streak_state';

  @override
  Future<StreakState> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const StreakState();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final lastOpened = json['lastOpenedDay'] as String?;
    return StreakState(
      count: json['count'] as int? ?? 0,
      lastOpenedDay: lastOpened == null ? null : DateTime.parse(lastOpened),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
    );
  }

  @override
  Future<void> save(StreakState state) async {
    await _prefs.setString(
      _key,
      jsonEncode({
        'count': state.count,
        'lastOpenedDay': state.lastOpenedDay?.toIso8601String(),
        'schemaVersion': state.schemaVersion,
      }),
    );
  }
}
