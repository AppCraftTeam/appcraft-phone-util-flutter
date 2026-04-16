import 'package:appcraft_phone_util_flutter/appcraft_phone_util_flutter.dart'
    as canonical;
import 'package:appcraft_phone_util_flutter/ac_phone_util.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('canonical entry-point re-exports legacy API', () {
    test('ACPhoneUtil доступен через оба import', () {
      expect(canonical.ACPhoneUtil, same(legacy.ACPhoneUtil));
    });

    test('ACPhoneCountry доступен через оба import', () {
      expect(canonical.ACPhoneCountry, same(legacy.ACPhoneCountry));
    });

    test('ACPhoneData доступен через оба import', () {
      expect(canonical.ACPhoneData, same(legacy.ACPhoneData));
    });

    test('ACPhoneEditingController доступен через оба import', () {
      expect(
        canonical.ACPhoneEditingController,
        same(legacy.ACPhoneEditingController),
      );
    });

    test('ACPhoneInputFormatter доступен через оба import', () {
      expect(
        canonical.ACPhoneInputFormatter,
        same(legacy.ACPhoneInputFormatter),
      );
    });
  });
}
