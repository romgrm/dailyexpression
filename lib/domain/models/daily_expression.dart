import 'cefr_level.dart';
import 'concept.dart';
import 'language_pair.dart';
import 'register.dart';

/// The presentation projection of a [Concept] for a given [LanguagePair],
/// following the corpus `daily_card_render` order. Pure content: the date is
/// supplied by the caller, keeping this independent of when it is shown.
class DailyExpression {
  const DailyExpression({
    required this.conceptId,
    required this.category,
    required this.categoryLabel,
    required this.level,
    required this.register,
    required this.idiom,
    required this.literalImage,
    required this.nativeEquivalent,
    required this.noEquivalentText,
    required this.meaning,
    required this.example,
    required this.exampleTranslation,
    this.variantLabel,
    this.nonEquivalenceNote,
  });

  /// Builds the projection for [pair]. Assumes [concept] is available for the
  /// pair (as guaranteed by `CorpusRepository.availableConcepts`). The native
  /// form may be absent (schema v2): [noEquivalentText] is then shown instead.
  factory DailyExpression.fromConcept(
    Concept concept,
    LanguagePair pair, {
    required String categoryLabel,
    required String noEquivalentText,
    String? variantLabel,
  }) {
    final targetForm = concept.forms[pair.target]!;
    final nativeForm = concept.forms[pair.native];
    final gloss = concept.glosses[pair.glossKey]!;
    return DailyExpression(
      conceptId: concept.id,
      category: concept.category,
      categoryLabel: categoryLabel,
      level: concept.level,
      register: concept.register,
      idiom: targetForm.text,
      literalImage: gloss.literal,
      nativeEquivalent: nativeForm?.text,
      noEquivalentText: noEquivalentText,
      variantLabel: variantLabel,
      meaning: concept.meaning[pair.native] ?? '',
      example: targetForm.example,
      exampleTranslation: gloss.exampleTranslation,
      nonEquivalenceNote: gloss.note,
    );
  }

  final String conceptId;
  final String category;
  final String categoryLabel;
  final CefrLevel level;
  final Register register;

  /// The idiom to learn (target language).
  final String idiom;

  /// Its word-for-word image in the native language.
  final String literalImage;

  /// The natural equivalent in the native language, or null when the concept
  /// has no established expression in that language.
  final String? nativeEquivalent;

  /// Localized placeholder shown when [nativeEquivalent] is null.
  final String noEquivalentText;

  /// Localized regional variant badge (e.g. 'Québécois'); null = pan-regional.
  final String? variantLabel;

  /// Short definition of the concept, in the native language.
  final String meaning;

  /// Example sentence in the target language.
  final String example;

  /// Translation of [example] into the native language.
  final String exampleTranslation;

  /// Present only when the couple has no direct idiom equivalent.
  final String? nonEquivalenceNote;

  bool get hasNativeEquivalent => nativeEquivalent != null;

  /// The native equivalent, or the localized placeholder when absent.
  String get nativeEquivalentOrPlaceholder =>
      nativeEquivalent ?? noEquivalentText;

  bool get isNonEquivalent => nonEquivalenceNote != null;
}
