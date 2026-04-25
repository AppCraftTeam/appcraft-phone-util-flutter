import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CHANGELOG.md is predominantly ASCII (pub.dev requirement)', () {
    final file = File('CHANGELOG.md');
    expect(file.existsSync(), isTrue, reason: 'CHANGELOG.md must exist');

    final content = file.readAsStringSync();
    final totalChars = content.length;
    final nonAsciiCount = content.runes.where((r) => r > 127).length;
    final nonAsciiRatio = nonAsciiCount / totalChars;

    // pub.dev penalises CHANGELOG with too many non-ASCII characters.
    // Exact threshold not documented; we enforce a strict 5% limit.
    expect(
      nonAsciiRatio,
      lessThan(0.05),
      reason: 'CHANGELOG.md non-ASCII ratio is '
          '${(nonAsciiRatio * 100).toStringAsFixed(1)}% '
          '(allowed < 5%). pub.dev penalises non-ASCII CHANGELOG.',
    );
  });
}
