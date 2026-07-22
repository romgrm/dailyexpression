import 'package:daily_expression/data/repositories/prefs_streak_repository.dart';
import 'package:daily_expression/domain/models/streak_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrefsStreakRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = PrefsStreakRepository(await SharedPreferences.getInstance());
  });

  test('reads an empty streak when nothing is stored', () async {
    final streak = await repository.read();

    expect(streak.count, 0);
    expect(streak.lastOpenedDay, isNull);
  });

  test('round-trips a saved streak', () async {
    final saved = StreakState(count: 7, lastOpenedDay: DateTime(2026, 7, 22));

    await repository.save(saved);
    final read = await repository.read();

    expect(read, saved);
  });
}
