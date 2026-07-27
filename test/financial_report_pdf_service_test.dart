import 'dart:convert';
import 'dart:io';

import 'package:finanzas_app_mobile/data/models/financial_report_data.dart';
import 'package:finanzas_app_mobile/data/services/financial_report_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temporaryDirectory;
  late FinancialReportPdfService service;
  late FinancialReportData report;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'finanzas_report_test_',
    );
    service = FinancialReportPdfService(
      directoryProvider: () async => temporaryDirectory,
    );
    report = FinancialReportData(
      periodLabel: 'Julio 2026',
      generatedAt: DateTime(2026, 7, 26, 14, 5, 9),
      totalIncome: 2000000,
      totalExpense: 500000,
      balance: 1500000,
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('genera un documento PDF válido con metadatos financieros', () async {
    final bytes = await service.buildPdf(report);
    final rawDocument = latin1.decode(bytes, allowInvalid: true);

    expect(bytes, isNotEmpty);
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(rawDocument, contains('Reporte financiero'));
    expect(rawDocument, contains('Finanzas App Mobile'));
    expect(rawDocument, contains('%%EOF'));
  });

  test('guarda el reporte en el directorio privado configurado', () async {
    final file = await service.createPdfFile(
      report: report,
      filePrefix: 'Reporte Mensual',
    );

    expect(await file.exists(), isTrue);
    expect(file.parent.path, temporaryDirectory.path);
    expect(file.path, endsWith('reporte_mensual_20260726_140509.pdf'));
    expect(await file.length(), greaterThan(1000));
  });
}
