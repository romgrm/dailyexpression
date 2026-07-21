/// A fully-resolved reminder handed to the notification service: when to fire
/// plus the already-localized text. [id] is stable per slot index so a
/// reschedule replaces the previous window cleanly.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.scheduledAt,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime scheduledAt;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledReminder &&
          other.id == id &&
          other.scheduledAt == scheduledAt &&
          other.title == title &&
          other.body == body;

  @override
  int get hashCode => Object.hash(id, scheduledAt, title, body);
}
