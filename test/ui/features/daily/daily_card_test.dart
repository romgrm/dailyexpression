import 'package:daily_expression/domain/models/cefr_level.dart';
import 'package:daily_expression/domain/models/concept.dart';
import 'package:daily_expression/domain/models/daily_expression.dart';
import 'package:daily_expression/domain/models/expression_form.dart';
import 'package:daily_expression/domain/models/gloss.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:daily_expression/domain/models/register.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/features/daily/view/widgets/daily_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pair = LanguagePair(native: 'fr', target: 'en');

DailyExpression expressionWith({String? note}) {
  final concept = Concept(
    id: 'rain_heavy',
    category: 'weather',
    level: CefrLevel.b1,
    register: Register.neutral,
    meaning: const {'fr': 'Pleuvoir très fort.'},
    forms: const {
      'en': ExpressionForm(
        text: "It's raining cats and dogs.",
        example: "We're staying in tonight, it's raining cats and dogs.",
      ),
      'fr': ExpressionForm(
        text: 'Il pleut des cordes.',
        example: 'On reste à la maison, il pleut des cordes.',
      ),
    },
    glosses: {
      'en_fr': Gloss(
        literal: 'Il pleut des chats et des chiens.',
        exampleTranslation: 'On reste à la maison ce soir.',
        note: note,
      ),
    },
    tags: const [],
  );
  return DailyExpression.fromConcept(
    concept,
    _pair,
    categoryLabel: 'Météo',
    noEquivalentText: 'Pas d\'équivalent direct en français',
  );
}

Widget wrap(Widget child) => MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('renders the fr -> en fields, no callout', (tester) async {
    await tester.pumpWidget(
      wrap(DailyCard(
        expression: expressionWith(),
        nativeLanguageName: 'Français',
        targetLanguageCode: 'en',
      )),
    );

    expect(find.text('"It\'s raining cats and dogs."'), findsOneWidget);
    expect(find.text('Il pleut des cordes.'), findsOneWidget);
    expect(find.textContaining('ÉQUIVALENT EN FRANÇAIS'), findsOneWidget);
    expect(find.textContaining('EN CONTEXTE'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsNothing);
  });

  testWidgets('shows the callout for a non-equivalent expression',
      (tester) async {
    await tester.pumpWidget(
      wrap(DailyCard(
        expression: expressionWith(note: 'Aucun idiome équivalent direct.'),
        nativeLanguageName: 'Français',
        targetLanguageCode: 'en',
      )),
    );

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.textContaining('Aucun idiome équivalent'), findsOneWidget);
  });
}
