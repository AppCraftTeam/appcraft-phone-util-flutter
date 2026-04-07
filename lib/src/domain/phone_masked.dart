class PhoneMasked {
  PhoneMasked._(this.maskedPhone);

  factory PhoneMasked.setMask(
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

    return PhoneMasked._(result.toString());
  }

  final String maskedPhone;
}