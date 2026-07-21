import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/core/logging/app_log.dart';
import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/models/daily_expression.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'daily_state.dart';

/// Loads today's expression for the user's pair (native -> English) and exposes
/// it as UI state. Selection determinism lives in [GetDailyExpression]; this
/// cubit only orchestrates fetching the pool, resolving, and projecting.
class DailyCubit extends Cubit<DailyState> {
  DailyCubit({
    required CorpusRepository corpus,
    required GetDailyExpression getDailyExpression,
    required Clock clock,
    required String uiLanguageCode,
    required String nativeLanguageCode,
  })  : _corpus = corpus,
        _getDailyExpression = getDailyExpression,
        _clock = clock,
        _uiLanguageCode = uiLanguageCode,
        _nativeLanguageCode = nativeLanguageCode,
        super(const DailyLoading()) {
    load();
  }

  final CorpusRepository _corpus;
  final GetDailyExpression _getDailyExpression;
  final Clock _clock;
  final String _uiLanguageCode;
  final String _nativeLanguageCode;

  static const _targetLanguageCode = 'en';

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
      final expression = DailyExpression.fromConcept(
        concept,
        pair,
        categoryLabel: config.categoryLabel(concept.category, _uiLanguageCode),
      );
      final nativeName =
          config.languageByCode(pair.native)?.displayName(_uiLanguageCode) ??
              pair.native;
      logger.d('[daily] loaded ${concept.id} for ${pair.glossKey}');
      emit(DailyLoaded(
        date: _clock.now(),
        expression: expression,
        nativeLanguageName: nativeName,
      ));
    } catch (error, stackTrace) {
      logger.e('[daily] load failed', error: error, stackTrace: stackTrace);
      emit(const DailyError());
    }
  }
}
