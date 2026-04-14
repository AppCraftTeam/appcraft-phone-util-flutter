import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:appcraft_phone_util_flutter/src/data/ac_phone_countries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Demo page showcasing [ACNationalPhoneEditingController] with an
/// externally selected country. The user picks a country from a dropdown,
/// and the text field accepts only the national part of the phone number.
class NationalPhoneDemoPage extends StatefulWidget {
  /// Creates a [NationalPhoneDemoPage].
  const NationalPhoneDemoPage({Key? key}) : super(key: key);

  @override
  State<NationalPhoneDemoPage> createState() => _NationalPhoneDemoPageState();
}

class _NationalPhoneDemoPageState extends State<NationalPhoneDemoPage> {
  late final List<ACPhoneCountry> _countries;
  late ACPhoneCountry _country;
  late final ACNationalPhoneEditingController _controller;

  @override
  void initState() {
    super.initState();
    _countries = ACPhoneCountries.instance.all;
    _country = _countries.firstWhere(
      (c) => c.isoCode == 'RU',
      orElse: () => _countries.first,
    );
    _controller = ACNationalPhoneEditingController(country: _country);
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _onCountryChanged(ACPhoneCountry? value) {
    if (value == null) {
      return;
    }
    setState(() {
      _country = value;
      _controller.country = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawPhoneNumber = _controller.rawPhoneNumber;
    final isValid = _controller.isValid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('National-phone демо'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<ACPhoneCountry>(
            value: _country,
            isExpanded: true,
            items: _countries
                .map(
                  (c) => DropdownMenuItem<ACPhoneCountry>(
                    value: c,
                    child: Text('${c.name} (${c.phoneCode})'),
                  ),
                )
                .toList(),
            onChanged: _onCountryChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            key: ValueKey<String>(_country.isoCode),
            controller: _controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ACPhoneInputFormatter(mask: _country.nationalMask),
            ],
            decoration: InputDecoration(
              labelText: 'Национальный номер',
              hintText: _country.nationalMask,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Страна',
                    value: '${_country.name} (${_country.isoCode})',
                  ),
                  _InfoRow(
                    label: 'Маска',
                    value: _country.nationalMask,
                  ),
                  _InfoRow(
                    label: 'Raw',
                    value: rawPhoneNumber.isNotEmpty ? rawPhoneNumber : '-',
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Валиден:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        isValid ? Icons.check : Icons.close,
                        color: isValid ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
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
