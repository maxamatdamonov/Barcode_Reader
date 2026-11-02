import 'package:barcode_reader/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home presents scan entry point', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Barcode Reader'), findsOneWidget);
    expect(find.text('Skanerlashni boshlash'), findsOneWidget);
    expect(find.byType(ScanResult), findsNothing);
  });

  testWidgets('Result copies exact content and allows another scan', (
    tester,
  ) async {
    String? copied;
    var scannedAgain = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScanResult(
            value: '0123456789012',
            format: 'ean13',
            onScanAgain: () => scannedAgain = true,
          ),
        ),
      ),
    );
    expect(find.text('0123456789012'), findsOneWidget);
    await tester.tap(find.text('Nusxalash'));
    await tester.pump();
    expect(copied, '0123456789012');
    expect(find.text('Natija nusxalandi'), findsOneWidget);
    await tester.tap(find.text('Yana skanerlash'));
    expect(scannedAgain, isTrue);
    expect(tester.takeException(), isNull);
  });
}
