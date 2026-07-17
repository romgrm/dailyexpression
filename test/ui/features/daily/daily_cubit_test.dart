import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'package:daily_expression/ui/features/daily/cubit/daily_cubit.dart';
import 'package:daily_expression/ui/features/daily/cubit/daily_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/in_memory_daily_log.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DailyCubit buildCubit(String nativeCode) {
    final clock = FakeClock(DateTime(2026, 7, 17));
    return DailyCubit(
      corpus: CorpusRepository(CorpusLocalDataSource()),
      getDailyExpression: GetDailyExpression(
        log: InMemoryDailyLog(),
        clock: clock,
        userSeed: 'seed-A',
      ),
      clock: clock,
      uiLanguageCode: 'fr',
      nativeLanguageCode: nativeCode,
    );
  }

  test('loads today\'s expression for fr -> en', () async {
    final cubit = buildCubit('fr');
    await cubit.stream.firstWhere((state) => state is! DailyLoading);

    final state = cubit.state;
    expect(state, isA<DailyLoaded>());
    final loaded = state as DailyLoaded;
    expect(loaded.expression.idiom, isNotEmpty);
    expect(loaded.expression.nativeEquivalent, isNotEmpty);
    expect(loaded.nativeLanguageName, 'Français');
  });

  test('emits DailyError for a pair with no concepts', () async {
    final cubit = buildCubit('de'); // 'de' is not an active native language
    await cubit.stream.firstWhere((state) => state is! DailyLoading);

    expect(cubit.state, isA<DailyError>());
  });
}
