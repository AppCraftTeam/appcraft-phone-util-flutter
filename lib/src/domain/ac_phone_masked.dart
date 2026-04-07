/// Applies a mask pattern to a raw phone number string.
class ACPhoneMasked {
  ACPhoneMasked._(this.maskedPhone);

  /// Creates an [ACPhoneMasked] by applying [mask] to [rawPhone].
  ///
  /// The '#' characters in [mask] are replaced with digits from [rawPhone].
  factory ACPhoneMasked.setMask(
    String mask,
    { required String rawPhone }
  ) {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final result = StringBuffer();
    var digitIndex = 0;

    for (var i = 0; i < mask.length; i++) {
      if (mask[i] == '#') {
        if (digitIndex < digits.length) {
          result.write(digits[digitIndex]);
          digitIndex++;
        } else {
          break;
        }
      } else {
        result.write(mask[i]);
      }
    }

    return ACPhoneMasked._(result.toString());
  }

  /// The resulting masked phone number string.
  final String maskedPhone;
}
