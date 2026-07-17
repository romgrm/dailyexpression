/// Abstraction over the current time so selection logic is deterministic and
/// testable (inject a fake in tests).
abstract interface class Clock {
  DateTime now();
}

/// Real clock backed by the device time.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// The local calendar day of [dateTime], formatted `yyyy-MM-dd`. This is the
/// day boundary the daily selection and the reminders share.
String dayKeyOf(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
