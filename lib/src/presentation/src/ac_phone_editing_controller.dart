import 'package:flutter/widgets.dart';

import '../../ac_phone_util.dart';
import '../../domain/ac_phone_country.dart';
import '../../domain/ac_phone_data.dart';

/// A [TextEditingController] that automatically parses phone numbers
/// using [ACPhoneUtil] whenever the text changes.
///
/// Provides reactive access to [phoneData], [isValid], [country]
/// and [rawPhoneNumber] based on the current text value.
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
    _phoneData = ACPhoneUtil.instance.findPhone(
      phoneNumber: text,
    );
  }

  @override
  void dispose() {
    removeListener(_onTextChanged);
    super.dispose();
  }
}
