import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ExampleApp());
}

/// Root application widget for the phone util example.
class ExampleApp extends StatelessWidget {
  /// Creates an [ExampleApp].
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Phone Util Example',
    theme: ThemeData(
      colorSchemeSeed: Colors.blue,
      useMaterial3: true,
    ),
    home: const PhoneInputExampleScreen(),
  );
}

/// Screen demonstrating two phone input variants:
/// auto-detect and fixed country.
class PhoneInputExampleScreen extends StatefulWidget {
  /// Creates a [PhoneInputExampleScreen].
  const PhoneInputExampleScreen({Key? key}) : super(key: key);

  @override
  State<PhoneInputExampleScreen> createState() =>
      _PhoneInputExampleScreenState();
}

class _PhoneInputExampleScreenState extends State<PhoneInputExampleScreen> {
  // -- Variant 1: Auto-detect --
  late final ACPhoneEditingController _autoController;

  // -- Variant 2: Fixed country --
  late final TextEditingController _fixedController;
  late List<ACPhoneCountry> _countries;
  ACPhoneCountry? _selectedCountry;
  ACPhoneData? _fixedPhoneData;

  @override
  void initState() {
    super.initState();
    _autoController = ACPhoneEditingController();
    _fixedController = TextEditingController();
    _countries = ACPhoneUtil.instance.getCountries();
    _selectedCountry = _countries.first;
  }

  @override
  void dispose() {
    _autoController.dispose();
    _fixedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Phone Util Example'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAutoDetectSection(),
        const Divider(height: 48),
        _buildFixedCountrySection(),
      ],
    ),
  );

  // ---------------------------------------------------------------------------
  // Variant 1: Auto-detect
  // ---------------------------------------------------------------------------

  Widget _buildAutoDetectSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Variant 1: Auto-detect country',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _autoController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')),
          ACPhoneInputFormatter(),
        ],
        decoration: const InputDecoration(
          labelText: 'Phone number',
          hintText: 'Enter phone number with country code',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 8),
      _buildPhoneInfo(
        country: _autoController.country,
        rawNumber: _autoController.rawPhoneNumber,
        isValid: _autoController.isValid,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Variant 2: Fixed country
  // ---------------------------------------------------------------------------

  Widget _buildFixedCountrySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Variant 2: Fixed country',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      DropdownButton<ACPhoneCountry>(
        value: _selectedCountry,
        isExpanded: true,
        items: _countries
            .map(
              (country) => DropdownMenuItem<ACPhoneCountry>(
                value: country,
                child: Text(
                  '${country.name} (${country.phoneCode})',
                ),
              ),
            )
            .toList(),
        onChanged: (country) {
          setState(() {
            _selectedCountry = country;
            _fixedController.clear();
            _fixedPhoneData = null;
          });
        },
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _fixedController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          if (_selectedCountry != null)
            ACPhoneInputFormatter(
              country: _selectedCountry,
              onPhoneChanged: (data) {
                setState(() {
                  _fixedPhoneData = data;
                });
              },
            ),
        ],
        decoration: InputDecoration(
          labelText: 'Phone number',
          hintText: _selectedCountry?.mask ?? 'Select a country first',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      _buildPhoneInfo(
        country: _fixedPhoneData?.country,
        rawNumber: _fixedPhoneData?.rawPhoneNumber ?? '',
        isValid: _fixedPhoneData != null &&
            ACPhoneUtil.instance.phoneIsValid(
              phoneNumber: _fixedController.text,
            ),
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Shared info display
  // ---------------------------------------------------------------------------

  Widget _buildPhoneInfo({
    required ACPhoneCountry? country,
    required String rawNumber,
    required bool isValid,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            'Country',
            country != null
                ? '${country.name} (${country.isoCode})'
                : '-',
          ),
          _infoRow(
            'Phone code',
            country?.phoneCode ?? '-',
          ),
          _infoRow(
            'Raw number',
            rawNumber.isNotEmpty ? rawNumber : '-',
          ),
          _infoRow(
            'Valid',
            isValid ? 'Yes' : 'No',
          ),
        ],
      ),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
