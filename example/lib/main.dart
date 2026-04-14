import 'package:flutter/material.dart';

import 'auto_detect_demo_page.dart';
import 'national_phone_demo_page.dart';

void main() {
  runApp(const ExampleApp());
}

/// Root application widget for the phone util example.
class ExampleApp extends StatelessWidget {
  /// Creates an [ExampleApp].
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ACPhoneUtil example',
    theme: ThemeData(
      colorSchemeSeed: Colors.blue,
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

/// Home screen with navigation to the two demo pages:
/// [AutoDetectDemoPage] and [NationalPhoneDemoPage].
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('ACPhoneUtil example'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AutoDetectDemoPage(),
              ),
            ),
            child: const Text('Auto-detect'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NationalPhoneDemoPage(),
              ),
            ),
            child: const Text('National phone'),
          ),
        ],
      ),
    ),
  );
}
