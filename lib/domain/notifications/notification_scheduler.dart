import '../models/scheduled_reminder.dart';

/// Port over the platform's local-notification capability. The domain speaks in
/// [ScheduledReminder]s; the data layer adapts to the operating-system
/// scheduler. Keeping it an interface lets the coordinator be unit-tested with a
/// fake, while the real plugin is exercised on device.
abstract interface class NotificationScheduler {
  /// Prepares the platform channel and timezone database. Idempotent.
  Future<void> init();

  /// Asks the user for permission to post notifications. Returns whether it was
  /// granted (true on platforms that do not gate it).
  Future<bool> requestPermission();

  /// Replaces the pending window with [reminders], each fired at its local
  /// [ScheduledReminder.scheduledAt].
  Future<void> schedule(List<ScheduledReminder> reminders);

  /// Cancels every pending notification.
  Future<void> cancelAll();
}
