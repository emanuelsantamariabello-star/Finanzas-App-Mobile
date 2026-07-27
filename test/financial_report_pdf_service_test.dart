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
      userName: 'Emanuel Santamaría',
      periodLabel: 'Julio 2026',
      generatedAt: DateTime(2026, 7, 26, 14, 5, 9),
      totalIncome: 2000000,
      totalExpense: 500000,
      balance: 1500000,
      movements: [
        FinancialReportMovement(
          type: FinancialMovementType.income,
          date: DateTime(2026, 7, 15),
          description: 'Pago de nómina',
          category: 'Quincenal',
          amount: 2000000,
        ),
        FinancialReportMovement(
          type: FinancialMovementType.expense,
          date: DateTime(2026, 7, 20),
          description: 'Educación',
          category: 'Quincenal',
          amount: 500000,
          reflectionType: 'necesario',
        ),
      ],
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

  test('distribuye un historial extenso en varias páginas', () async {
    final extensiveReport = FinancialReportData(
      userName: 'Usuario de prueba',
      periodLabel: 'Historial completo',
      generatedAt: DateTime(2026, 7, 26),
      totalIncome: 8000000,
      totalExpense: 4000000,
      balance: 4000000,
      movements: List.generate(
        80,
        (index) => FinancialReportMovement(
          type: index.isEven
              ? FinancialMovementType.income
              : FinancialMovementType.expense,
          date: DateTime(2026, 7, 26).subtract(Duration(days: index)),
          description: 'Movimiento financiero número $index',
          category: index.isEven ? 'Ingreso' : 'Gasto',
          amount: 100000 + index,
          reflectionType: index.isEven ? null : 'necesario',
        ),
      ),
    );

    final bytes = await service.buildPdf(extensiveReport);
    final rawDocument = latin1.decode(bytes, allowInvalid: true);
    final pageCount = RegExp(r'/Type\s*/Page\b').allMatches(rawDocument).length;

    expect(pageCount, greaterThan(1));
  });
}
