import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// One-off generator: rasterizes the brand icon SVG to a 1024×1024 PNG for
/// `flutter_launcher_icons`. Run with:
///   flutter test tool/generate_app_icon.dart
void main() {
  test('generate assets/brand/app_icon.png from the SVG source', () async {
    final raw = await File('assets/brand/app_icon.svg').readAsString();
    final pictureInfo = await vg.loadPicture(SvgStringLoader(raw), null);
    final image = await pictureInfo.picture.toImage(1024, 1024);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    await File('assets/brand/app_icon.png')
        .writeAsBytes(bytes!.buffer.asUint8List());

    pictureInfo.picture.dispose();
    image.dispose();
    expect(await File('assets/brand/app_icon.png').exists(), isTrue);
  });
}
