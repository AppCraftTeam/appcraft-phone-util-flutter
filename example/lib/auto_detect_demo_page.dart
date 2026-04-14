import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter/material.dart';

/// Demo page showcasing [ACPhoneEditingController] with automatic
/// country detection from the entered phone number.
class AutoDetectDemoPage extends StatefulWidget {
  /// Creates an [AutoDetectDemoPage].
  const AutoDetectDemoPage({Key? key}) : super(key: key);

  @override
  State<AutoDetectDemoPage> createState() => _AutoDetectDemoPageState();
}

class _AutoDetectDemoPageState extends State<AutoDetectDemoPage> {
  late final ACPhoneEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ACPhoneEditingController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final country = _controller.country;
    final rawPhoneNumber = _controller.rawPhoneNumber;
    final isValid = _controller.isValid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-detect демо'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Номер телефона',
              hintText: 'Введите номер с кодом страны',
              border: OutlineInputBorder(),
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
                    value: country?.name ?? 'не определена',
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
