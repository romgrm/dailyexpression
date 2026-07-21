import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Font family names registered by [loadGoldenFonts]. Golden themes reference
/// these directly so snapshots render real glyphs instead of the blank
/// flutter_test placeholder box font.
const goldenSerifFont = 'Fraunces';
const goldenSansFont = 'Roboto';

var _loaded = false;

/// Loads the vendored brand fonts into the test font registry so golden tests
/// produce readable, on-device-faithful text.
///
/// The app pulls Fraunces through `google_fonts` at runtime, which cannot fetch
/// inside the offline test zone. The TTFs live under `assets/fonts/` for test
/// use only — they are deliberately NOT declared in `pubspec.yaml` assets to
/// keep them out of the production bundle, so they are read straight from disk
/// (tests run with the package root as the working directory). Idempotent, so
/// it is safe to call from `setUpAll` in every golden suite.
Future<void> loadGoldenFonts() async {
  if (_loaded) return;
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadFont(goldenSerifFont, 'assets/fonts/Fraunces.ttf');
  await _loadFont(goldenSansFont, 'assets/fonts/Roboto.ttf');

  _loaded = true;
}

Future<void> _loadFont(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final data = ByteData.view(Uint8List.fromList(bytes).buffer);
  await (FontLoader(family)..addFont(Future<ByteData>.value(data))).load();
}
