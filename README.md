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

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  appcraft_phone_util_flutter:
    git:
      url: https://github.com/AppCraftTeam/appcraft-phone-util-flutter
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

### Using ACPhoneInputFormatter with TextField (auto-detect)

The formatter automatically detects the country from entered digits and applies the corresponding mask.

```dart
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    ACPhoneInputFormatter(
      onPhoneChanged: (ACPhoneData? data) {
        if (data != null) {
          print(data.phoneNumberMasked);
          print(data.country.name);
        }
      },
    ),
  ],
)
```

### Using ACPhoneInputFormatter with a fixed country

When a country is provided, the formatter always applies that country's mask regardless of the entered digits.

```dart
final countries = ACPhoneUtil.instance.getCountries();
final russia = countries.firstWhere((c) => c.isoCode == 'RU');

TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    ACPhoneInputFormatter(
      country: russia,
      onPhoneChanged: (ACPhoneData? data) {
        print(data?.phoneNumberMasked);
      },
    ),
  ],
)
```

### Using ACPhoneEditingController

The controller parses phone data automatically as the user types, providing reactive access to validation and country information.

```dart
final controller = ACPhoneEditingController();

// Use with TextField
TextField(
  controller: controller,
  keyboardType: TextInputType.phone,
)

// Access phone data
print(controller.phoneData?.phoneNumberMasked);
print(controller.isValid);
print(controller.country?.name);
print(controller.rawPhoneNumber);

// Set phone number programmatically
controller.setPhoneNumber('79161234567');

// Dispose when done
controller.dispose();
```

## License

See [LICENSE](LICENSE) for details.
