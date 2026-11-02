import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Barcode Reader',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F8C)),
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Barcode Reader')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 112,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 28),
              Text(
                'Kodni bir zumda o‘qing',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Shtrix-kod yoki QR-kodni kameraga qarating. '
                'Natijani ko‘ring va nusxalang.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Skanerlashni boshlash'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ScannerPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  Barcode? _result;
  int _attempt = 0;

  void _onDetect(BarcodeCapture capture) {
    if (!mounted || _result != null) return;
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue?.isNotEmpty ?? false) {
        setState(() => _result = barcode);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(result == null ? 'Kodni skanerlang' : 'Natija'),
      ),
      body: SafeArea(
        child: result != null
            ? ScanResult(
                value: result.rawValue!,
                format: result.format.name,
                onScanAgain: () => setState(() {
                  _result = null;
                  _attempt++;
                }),
              )
            : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Kodni kameraga aniq ko‘rinadigan qilib tuting.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: MobileScanner(
                      key: ValueKey(_attempt),
                      onDetect: _onDetect,
                      tapToFocus: true,
                      errorBuilder: (context, error) => Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.no_photography_outlined,
                                size: 56,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Kamerani ochib bo‘lmadi. Telefon '
                                'sozlamalarida ilovaga kamera ruxsatini bering '
                                'va kamera boshqa ilovada band emasligini tekshiring.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => setState(() => _attempt++),
                                child: const Text('Qayta urinish'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'QR-kod • EAN • UPC • Code 128 va boshqalar',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ScanResult extends StatelessWidget {
  const ScanResult({
    super.key,
    required this.value,
    required this.format,
    required this.onScanAgain,
  });

  final String value;
  final String format;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Kod topildi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text('Format: $format', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(value),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Nusxalash'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Natija nusxalandi')),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Yana skanerlash'),
            onPressed: onScanAgain,
          ),
        ],
      ),
    ),
  );
}
