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

  /// Whether notifications are currently authorized, without prompting.
  Future<bool> hasPermission();

  /// Opens the OS notification settings page for this app. The only recovery
  /// path once the user has denied permission, since the OS won't re-prompt.
  Future<void> openSystemSettings();

  /// Replaces the pending window with [reminders], each fired at its local
  /// [ScheduledReminder.scheduledAt].
  Future<void> schedule(List<ScheduledReminder> reminders);

  /// Posts [reminder] immediately. Used to preview a reminder on demand.
  Future<void> showNow(ScheduledReminder reminder);

  /// Cancels every pending notification.
  Future<void> cancelAll();
}
