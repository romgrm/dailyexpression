import 'cefr_level.dart';
import 'expression_form.dart';
import 'gloss.dart';
import 'language_pair.dart';
import 'register.dart';

/// A pivot idiom concept carrying its natural forms in every language, plus the
/// per-couple glosses. Identity is the stable [id] (never the list position),
/// so the corpus can grow and reorder without affecting selection or history.
class Concept {
  const Concept({
    required this.id,
    required this.category,
    required this.level,
    required this.register,
    required this.meaning,
    required this.forms,
    required this.glosses,
    required this.tags,
  });

  final String id;
  final String category;
  final CefrLevel level;
  final Register register;
  final Map<String, String> meaning;
  final Map<String, ExpressionForm> forms;
  final Map<String, Gloss> glosses;
  final List<String> tags;

  /// Whether this concept can be shown for [pair] (schema v2): it must carry the
  /// target form, the couple's gloss, and the meaning in the native language.
  /// The native form is OPTIONAL — when absent the UI shows a "no equivalent"
  /// placeholder instead of the native equivalent.
  bool isAvailableFor(LanguagePair pair) =>
      forms.containsKey(pair.target) &&
      glosses.containsKey(pair.glossKey) &&
      meaning.containsKey(pair.native);
}
