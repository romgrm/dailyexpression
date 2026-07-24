import 'package:daily_expression/domain/models/daily_expression.dart';

/// UI state for the daily card screen.
sealed class DailyState {
  const DailyState();
}

class DailyLoading extends DailyState {
  const DailyLoading();
}

class DailyLoaded extends DailyState {
  const DailyLoaded({
    required this.date,
    required this.expression,
    required this.nativeLanguageName,
    required this.targetLanguageCode,
    required this.streakCount,
  });

  final DateTime date;
  final DailyExpression expression;

  /// The native language's own name (e.g. 'Français'), for the equivalent block.
  final String nativeLanguageName;

  /// The target language's two-letter code (e.g. 'en'), for pronunciation.
  final String targetLanguageCode;

  /// The consecutive-day open streak, incremented on this app open.
  final int streakCount;
}

class DailyError extends DailyState {
  const DailyError();
}
