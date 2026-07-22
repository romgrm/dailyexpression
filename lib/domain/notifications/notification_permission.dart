/// The three states of the OS notification permission, collapsing the runtime
/// authorization (from the OS) and our persisted "already asked" flag into a
/// single value the UI can switch on.
enum NotificationPermission {
  /// Never prompted yet. Tapping should show the native OS permission dialog.
  notDetermined,

  /// Prompted and refused. The OS won't prompt again, so the UI must route the
  /// user to the system settings to re-enable.
  denied,

  /// Currently authorized.
  granted,
}
