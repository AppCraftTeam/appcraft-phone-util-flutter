import 'package:flutter/widgets.dart';

import '../../ac_phone_util.dart';
import '../../domain/ac_phone_country.dart';
import '../../domain/ac_phone_data.dart';

/// A [TextEditingController] that automatically parses phone numbers
/// using [ACPhoneUtil] whenever the text changes.
///
/// Provides reactive access to [phoneData], [isValid], [country]
/// and [rawPhoneNumber] based on the current text value.
///
/// In addition, whenever the detected country's phone code differs from
/// the leading digits of the current text (for example, a Russian number
/// entered with the national trunk-prefix `8` such as `89008007060`),
/// the controller surgically rewrites those leading digits in place with
/// the digits of the detected country's phone code. Only the first N digit
/// characters (where N is the length of the phone code without `+`) are
/// replaced; all other characters, including any mask separators such as
/// `+`, `(`, `)`, spaces or dashes, are preserved. Masking itself is still
/// the responsibility of an input formatter (e.g. `ACPhoneInputFormatter`).
class ACPhoneEditingController extends TextEditingController {
  /// Creates an [ACPhoneEditingController].
  ///
  /// If [initialPhoneNumber] is provided, the controller's text
  /// is initialized with it and phone data is parsed immediately.
  ACPhoneEditingController({String? initialPhoneNumber})
      : super(text: initialPhoneNumber) {
    _onTextChanged();
    addListener(_onTextChanged);
  }

  ACPhoneData? _phoneData;

  /// Re-entry guard for [_onTextChanged].
  ///
  /// When the controller programmatically rewrites [text] to replace the
  /// trunk-prefix, the listener fires again. This flag prevents a second
  /// rewrite pass inside the same cycle (infinite recursion guard).
  bool _isRewriting = false;

  /// Current parsed phone data, or `null` if the text does not
  /// contain a recognizable phone number.
  ACPhoneData? get phoneData => _phoneData;

  /// Whether the current text represents a valid phone number
  /// matching a known country mask completely.
  bool get isValid => ACPhoneUtil.instance.phoneIsValid(
    phoneNumber: text,
  );

  /// The detected [ACPhoneCountry] for the current phone number,
  /// or `null` if no country could be determined.
  ACPhoneCountry? get country => _phoneData?.country;

  /// The raw phone number extracted from [phoneData] (digits and '+' only).
  ///
  /// Returns an empty string if no phone data is available.
  String get rawPhoneNumber => _phoneData?.rawPhoneNumber ?? '';

  /// Sets the phone number programmatically.
  ///
  /// This updates [text], which triggers re-parsing of phone data.
  void setPhoneNumber(String phoneNumber) {
    text = phoneNumber;
  }

  void _onTextChanged() {
    if (_isRewriting) return;

    _phoneData = ACPhoneUtil.instance.findPhone(
      phoneNumber: text,
    );

    if (_phoneData == null) return;

    final codeDigits = _phoneData!.country.phoneCode.replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (codeDigits.isEmpty) return;

    final leadingDigits = _firstNDigits(text, codeDigits.length);
    if (leadingDigits == codeDigits) return;

    _applyTrunkPrefixRewrite(_phoneData!);
  }

  /// Rewrites the first N digit characters of [text] with the digits of
  /// [phoneData]'s country phone code, preserving every non-digit character
  /// as well as any digits beyond the first N.
  ///
  /// The caret position is preserved by digit-count: the number of digit
  /// characters located before the caret in the old [text] is mapped to an
  /// offset in the new text such that the same number of digits remains to
  /// the left of the caret. Non-digit mask separators do not affect the
  /// mapping.
  ///
  /// Guarded by [_isRewriting] to avoid recursive listener invocations.
  void _applyTrunkPrefixRewrite(ACPhoneData phoneData) {
    final codeDigits = phoneData.country.phoneCode.replaceAll(
      RegExp(r'\D'),
      '',
    );
    final oldText = text;
    final oldOffset = selection.baseOffset;

    final buffer = StringBuffer();
    var replaced = 0;
    for (var i = 0; i < oldText.length; i++) {
      final char = oldText[i];
      if (_isDigit(char.codeUnitAt(0)) && replaced < codeDigits.length) {
        buffer.write(codeDigits[replaced]);
        replaced++;
      } else {
        buffer.write(char);
      }
    }
    final newText = buffer.toString();

    final int newOffset;
    if (oldOffset < 0 || oldOffset > oldText.length) {
      newOffset = newText.length;
    } else {
      final digitsBefore = _countDigits(oldText, oldOffset);
      newOffset = _mapCursorByDigitCount(newText, digitsBefore);
    }

    _isRewriting = true;
    try {
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    } finally {
      _isRewriting = false;
    }
  }

  /// Returns the first [n] digit characters of [source] as a string.
  ///
  /// If [source] contains fewer than [n] digits, the returned string
  /// contains all digits found.
  String _firstNDigits(String source, int n) {
    final buffer = StringBuffer();
    for (var i = 0; i < source.length && buffer.length < n; i++) {
      final char = source[i];
      if (_isDigit(char.codeUnitAt(0))) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Whether [codeUnit] is an ASCII digit (`0`-`9`).
  bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

  /// Counts digit characters in [source] within `[0, end)`.
  int _countDigits(String source, int end) {
    final limit = end > source.length ? source.length : end;
    var count = 0;
    for (var i = 0; i < limit; i++) {
      if (_isDigit(source.codeUnitAt(i))) count++;
    }
    return count;
  }

  /// Returns the offset in [newText] located immediately after the
  /// [digitsBefore]-th digit. If [newText] contains fewer digits, returns
  /// [String.length] of [newText].
  int _mapCursorByDigitCount(String newText, int digitsBefore) {
    if (digitsBefore <= 0) return 0;
    var count = 0;
    for (var i = 0; i < newText.length; i++) {
      if (_isDigit(newText.codeUnitAt(i))) {
        count++;
        if (count == digitsBefore) return i + 1;
      }
    }
    return newText.length;
  }

  @override
  void dispose() {
    removeListener(_onTextChanged);
    super.dispose();
  }
}
