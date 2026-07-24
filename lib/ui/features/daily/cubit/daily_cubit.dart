import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/core/logging/app_log.dart';
import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/models/daily_expression.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:daily_expression/domain/models/streak_state.dart';
import 'package:daily_expression/domain/repositories/streak_repository.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'package:daily_expression/domain/use_cases/streak_calculator.dart';
import 'daily_state.dart';

/// Loads today's expression for the user's pair (native -> target) and exposes
/// it as UI state. Selection determinism lives in [GetDailyExpression]; this
/// cubit only orchestrates fetching the pool, resolving, and projecting.
class DailyCubit extends Cubit<DailyState> {
  DailyCubit({
    required CorpusRepository corpus,
    required GetDailyExpression getDailyExpression,
    required StreakRepository streakRepository,
    required Clock clock,
    required String uiLanguageCode,
    required String nativeLanguageCode,
    required String targetLanguageCode,
  })  : _corpus = corpus,
        _getDailyExpression = getDailyExpression,
        _streakRepository = streakRepository,
        _clock = clock,
        _uiLanguageCode = uiLanguageCode,
        _nativeLanguageCode = nativeLanguageCode,
        _targetLanguageCode = targetLanguageCode,
        super(const DailyLoading()) {
    load();
  }

  final CorpusRepository _corpus;
  final GetDailyExpression _getDailyExpression;
  final StreakRepository _streakRepository;
  final Clock _clock;
  final String _uiLanguageCode;
  final String _nativeLanguageCode;
  final String _targetLanguageCode;

  Future<void> load() async {
    emit(const DailyLoading());
    try {
      final pair = LanguagePair(
        native: _nativeLanguageCode,
        target: _targetLanguageCode,
      );
      final config = await _corpus.loadConfig();
      final pool = await _corpus.availableConcepts(pair);
      final concept = await _getDailyExpression(pair: pair, pool: pool);
      final variantCode = concept.forms[pair.target]?.variant;
      final expression = DailyExpression.fromConcept(
        concept,
        pair,
        categoryLabel: config.categoryLabel(concept.category, _uiLanguageCode),
        noEquivalentText: config.noEquivalentFor(pair.native),
        variantLabel: variantCode == null
            ? null
            : config.variantLabel(variantCode, _uiLanguageCode),
      );
      final nativeName =
          config.languageByCode(pair.native)?.displayName(_uiLanguageCode) ??
              pair.native;
      final streak = await _registerOpen();
      logger.d('[daily] loaded ${concept.id} for ${pair.glossKey}');
      emit(DailyLoaded(
        date: _clock.now(),
        expression: expression,
        nativeLanguageName: nativeName,
        targetLanguageCode: pair.target,
        streakCount: streak.count,
      ));
    } catch (error, stackTrace) {
      logger.e('[daily] load failed', error: error, stackTrace: stackTrace);
      emit(const DailyError());
    }
  }

  /// Advances the streak for this app open and persists it when it changed.
  /// Idempotent within a day, so a retry or cubit rebuild never double-counts.
  Future<StreakState> _registerOpen() async {
    final previous = await _streakRepository.read();
    final updated = nextStreak(previous, _clock.now());
    if (updated != previous) await _streakRepository.save(updated);
    return updated;
  }
}
