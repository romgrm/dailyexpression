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
  });

  final DateTime date;
  final DailyExpression expression;

  /// The native language's own name (e.g. 'Français'), for the equivalent block.
  final String nativeLanguageName;
}

class DailyError extends DailyState {
  const DailyError();
}
