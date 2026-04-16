# appcraft_phone_util_flutter

A Flutter library for phone number parsing, validation, formatting and country detection.

## Features

- **Phone number parsing** -- detect country and format phone numbers automatically
- **Validation** -- check whether a phone number matches a known country mask
- **Country detection** -- identify country by phone code (200+ countries supported)
- **Localized country names** -- 36 languages via `ACPhoneCountryLocalizations`
- **Input formatter** -- `ACPhoneInputFormatter` for `TextField` with auto-detect and fixed country modes
- **Editing controller** -- `ACPhoneEditingController` with reactive phone data, validation and country access

## Installation

### From pub.dev (recommended)

```bash
flutter pub add appcraft_phone_util_flutter
```

Or add to `pubspec.yaml` manually:

```yaml
dependencies:
  appcraft_phone_util_flutter: ^<current_version>
```

### From source

```yaml
dependencies:
  appcraft_phone_util_flutter:
    git:
      url: https://github.com/AppCraftTeam/appcraft-phone-util-flutter
      ref: <current_version>
```

Then run:

```bash
flutter pub get
```

## Usage

### Import

```dart
import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
```

### Parsing a phone number

```dart
final phoneData = ACPhoneUtil.instance.findPhone(
  phoneNumber: '79161234567',
);

if (phoneData != null) {
  print(phoneData.phoneNumberMasked); // formatted number
  print(phoneData.country.name);      // country name
  print(phoneData.country.isoCode);   // ISO code
  print(phoneData.rawPhoneNumber);    // digits and '+' only
}
```

### Validating a phone number

```dart
final isValid = ACPhoneUtil.instance.phoneIsValid(
  phoneNumber: '79161234567',
);
print(isValid); // true or false
```

### Getting country list

```dart
// All countries
final countries = ACPhoneUtil.instance.getCountries();

// Localized country names
final localizedCountries = ACPhoneUtil.instance.getCountries(
  locale: const Locale('ru'),
);

// Search by name
final filtered = ACPhoneUtil.instance.getCountries(
  search: 'Germany',
);
```

### Auto-detect country with ACPhoneEditingController

`ACPhoneEditingController` parses entered digits, detects the country and provides reactive access to the parsed data. Pair it with `ACPhoneInputFormatter` for masked input.

```dart
final controller = ACPhoneEditingController();

TextField(
  controller: controller,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    ACPhoneInputFormatter(mask: '+# (###) ###-##-##'),
  ],
)

// Reactive access to parsed data
print(controller.phoneData?.phoneNumberMasked);
print(controller.country?.name);
print(controller.isValid);
print(controller.rawPhoneNumber);

// Set phone number programmatically
controller.setPhoneNumber('79161234567');

// Dispose when done
controller.dispose();
```

### Fixed country with ACNationalPhoneEditingController

When the country is selected externally (e.g. by a dropdown), use `ACNationalPhoneEditingController` — it accepts the national part of the number and formats it with the country's national mask.

```dart
final countries = ACPhoneUtil.instance.getCountries();
final russia = countries.firstWhere((c) => c.isoCode == 'RU');

final controller = ACNationalPhoneEditingController(country: russia);

TextField(
  controller: controller,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    ACPhoneInputFormatter(mask: russia.nationalMask),
  ],
)

// Change country at runtime
controller.country = countries.firstWhere((c) => c.isoCode == 'DE');

// Access the full phone number (country code + national part)
print(controller.rawPhoneNumber);
print(controller.isValid);

controller.dispose();
```

## License

See [LICENSE](LICENSE) for details.
