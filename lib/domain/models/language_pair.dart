/// A language pairing: learning [target] from the user's [native] language.
class LanguagePair {
  const LanguagePair({required this.native, required this.target});

  final String native;
  final String target;

  /// Key into a concept's glosses map, e.g. 'en_fr'.
  String get glossKey => '${target}_$native';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePair &&
          other.native == native &&
          other.target == target;

  @override
  int get hashCode => Object.hash(native, target);
}
