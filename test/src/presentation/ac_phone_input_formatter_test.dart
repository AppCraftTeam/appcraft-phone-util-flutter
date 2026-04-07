import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _formatValue(
  TextInputFormatter formatter,
  String text,
) =>
    formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );

TextEditingValue _formatDeletion(
  TextInputFormatter formatter, {
  required TextEditingValue oldValue,
  required TextEditingValue newValue,
}) =>
    formatter.formatEditUpdate(oldValue, newValue);

void main() {
  group('ACPhoneInputFormatter', () {
    group('auto-detect country (country == null)', () {
      test('formats Russian number from raw digits', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '79161234567');

        // Assert
        expect(result.text, '+7 (916) 123-45-67');
      });

      test('formats US number from raw digits', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '12025551234');

        // Assert
        expect(result.text, '+1 (202) 555 1234');
      });

      test('formats partial Russian number', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '7916');

        // Assert
        // ACPhoneUtil._applyMask stops after consuming all digits,
        // trailing literal chars after last '#' are not appended.
        expect(result.text, '+7 (916');
      });

      test('returns empty for empty input', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '');

        // Assert
        expect(result.text, '');
      });

      test('detects country change when code changes', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act - first Russian
        final resultRu = _formatValue(formatter, '79161234567');

        // Assert
        expect(resultRu.text, '+7 (916) 123-45-67');

        // Act - then US
        final resultUs = _formatValue(formatter, '12025551234');

        // Assert
        expect(resultUs.text, '+1 (202) 555 1234');
      });
    });

    group('fixed country (country != null)', () {
      test('formats with fixed Russian country mask', () {
        // Arrange
        const ruCountry = ACPhoneCountry(
          name: 'Russian Federation',
          isoCode: 'RU',
          phoneCode: '+7',
          mask: '+# (###) ###-##-##',
          alternativePhoneCodes: [],
        );
        final formatter = ACPhoneInputFormatter(
          country: ruCountry,
        );

        // Act
        final result = _formatValue(formatter, '79161234567');

        // Assert
        expect(result.text, '+7 (916) 123-45-67');
      });

      test('formats digits without country code prefix using fixed mask', () {
        // Arrange
        const ruCountry = ACPhoneCountry(
          name: 'Russian Federation',
          isoCode: 'RU',
          phoneCode: '+7',
          mask: '+# (###) ###-##-##',
          alternativePhoneCodes: [],
        );
        final formatter = ACPhoneInputFormatter(
          country: ruCountry,
        );

        // Act
        final result = _formatValue(formatter, '9161234567');

        // Assert
        // Only 10 digits fit into 11-digit mask, so partial fill
        expect(result.text, '+9 (161) 234-56-7');
      });
    });

    group('non-digit characters', () {
      test('ignores non-digit characters in input', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '+7 (916) 123-45-67');

        // Assert
        expect(result.text, '+7 (916) 123-45-67');
      });

      test('ignores letters in input', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '7abc916def1234567');

        // Assert
        expect(result.text, '+7 (916) 123-45-67');
      });
    });

    group('paste long number', () {
      test('formats pasted full Russian number', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '+7 (916) 123-45-67');

        // Assert
        expect(result.text, '+7 (916) 123-45-67');
      });

      test('truncates extra digits beyond mask length', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act - extra digits beyond Russian mask
        final result = _formatValue(formatter, '7916123456789999');

        // Assert - mask has 11 digit slots, extra digits ignored
        expect(result.text, '+7 (916) 123-45-67');
      });
    });

    group('deletion', () {
      test('re-formats after deleting last character', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();
        const oldText = '+7 (916) 123-45-67';
        final oldValue = TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        );
        // Simulate backspace: remove last char
        final newText = oldText.substring(0, oldText.length - 1);
        final newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );

        // Act
        final result = _formatDeletion(
          formatter,
          oldValue: oldValue,
          newValue: newValue,
        );

        // Assert - re-formatted from digits extracted from newText
        // digits from "+7 (916) 123-45-6" = "791612345 6" = 10 digits
        expect(result.text, '+7 (916) 123-45-6');
      });

      test('re-formats after deleting middle character', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();
        const oldText = '+7 (916) 123-45-67';
        final oldValue = TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: 14),
        );
        // Delete '4' at index 13 -> "+7 (916) 123-5-67"
        const newText = '+7 (916) 123-5-67';
        final newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: 13),
        );

        // Act
        final result = _formatDeletion(
          formatter,
          oldValue: oldValue,
          newValue: newValue,
        );

        // Assert - digits from newText: "7916123567" = 10 digits
        expect(result.text, '+7 (916) 123-56-7');
      });
    });

    group('cursor position', () {
      test('cursor is at the end after formatting full number', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '79161234567');

        // Assert
        expect(
          result.selection,
          TextSelection.collapsed(offset: result.text.length),
        );
      });

      test('cursor is at end of partial formatted number', () {
        // Arrange
        final formatter = ACPhoneInputFormatter();

        // Act
        final result = _formatValue(formatter, '7916');

        // Assert
        expect(
          result.selection,
          TextSelection.collapsed(offset: result.text.length),
        );
      });
    });

    group('onPhoneChanged callback', () {
      test('calls onPhoneChanged with ACPhoneData on valid input', () {
        // Arrange
        ACPhoneData? receivedData;
        final formatter = ACPhoneInputFormatter(
          onPhoneChanged: (data) => receivedData = data,
        );

        // Act
        _formatValue(formatter, '79161234567');

        // Assert
        expect(receivedData, isNotNull);
        expect(receivedData!.phoneNumberMasked, '+7 (916) 123-45-67');
        expect(receivedData!.country.isoCode, 'RU');
      });

      test('calls onPhoneChanged with null on empty input', () {
        // Arrange
        ACPhoneData? receivedData = const ACPhoneData(
          phoneNumberMasked: 'placeholder',
          country: ACPhoneCountry(
            name: '',
            isoCode: '',
            phoneCode: '',
            mask: '',
            alternativePhoneCodes: [],
          ),
        );
        final formatter = ACPhoneInputFormatter(
          onPhoneChanged: (data) => receivedData = data,
        );

        // Act
        _formatValue(formatter, '');

        // Assert
        expect(receivedData, isNull);
      });

      test('calls onPhoneChanged with updated data when country changes', () {
        // Arrange
        final phoneDatas = <ACPhoneData?>[];
        final formatter = ACPhoneInputFormatter(
          onPhoneChanged: (data) => phoneDatas.add(data),
        );

        // Act
        _formatValue(formatter, '79161234567');
        _formatValue(formatter, '12025551234');

        // Assert
        expect(phoneDatas.length, 2);
        expect(phoneDatas[0]!.country.isoCode, 'RU');
        expect(phoneDatas[1]!.country.isoCode, 'US');
      });

      test('calls onPhoneChanged with fixed country data', () {
        // Arrange
        const ruCountry = ACPhoneCountry(
          name: 'Russian Federation',
          isoCode: 'RU',
          phoneCode: '+7',
          mask: '+# (###) ###-##-##',
          alternativePhoneCodes: [],
        );
        ACPhoneData? receivedData;
        final formatter = ACPhoneInputFormatter(
          country: ruCountry,
          onPhoneChanged: (data) => receivedData = data,
        );

        // Act
        _formatValue(formatter, '79161234567');

        // Assert
        expect(receivedData, isNotNull);
        expect(receivedData!.country.isoCode, 'RU');
      });
    });
  });
}
