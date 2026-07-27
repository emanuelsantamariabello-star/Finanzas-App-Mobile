import 'dart:io';

import 'package:finanzas_app_mobile/data/models/financial_report_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

typedef ReportDirectoryProvider = Future<Directory> Function();

class FinancialReportPdfService {
  final ReportDirectoryProvider _directoryProvider;

  FinancialReportPdfService({ReportDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getTemporaryDirectory;

  Future<Uint8List> buildPdf(FinancialReportData report) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final document = pw.Document(
      title: 'Reporte financiero',
      author: 'Finanzas App Mobile',
      creator: 'Finanzas App Mobile',
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );
    final amountFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    );
    final generatedAtFormatter = DateFormat('dd/MM/yyyy HH:mm');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
          ),
        ),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 12,
                height: 38,
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF00C853),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Finanzas App Mobile',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF00A846),
                    ),
                  ),
                  pw.Text(
                    'Reporte financiero',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Período: ${report.periodLabel}',
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Usuario: ${report.userName}',
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11),
          ),
          pw.SizedBox(height: 28),
          pw.Text(
            'Resumen',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _buildMetric(
                label: 'Total ingresos',
                value: amountFormatter.format(report.totalIncome),
                color: const PdfColor.fromInt(0xFF00A846),
              ),
              pw.SizedBox(width: 10),
              _buildMetric(
                label: 'Total gastos',
                value: amountFormatter.format(report.totalExpense),
                color: const PdfColor.fromInt(0xFFD32F2F),
              ),
              pw.SizedBox(width: 10),
              _buildMetric(
                label: 'Balance',
                value: amountFormatter.format(report.balance),
                color: const PdfColor.fromInt(0xFF2979FF),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Text(
              'Estado financiero: ${report.financialStatus} · '
              '${report.expenseRatioSummary}.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Clasificación de gastos',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _buildClassification(
                label: 'Necesarios',
                percentage: report.necessaryPercentage,
                amount: amountFormatter.format(report.necessaryExpense),
                color: const PdfColor.fromInt(0xFF00A846),
              ),
              pw.SizedBox(width: 10),
              _buildClassification(
                label: 'Gustos',
                percentage: report.tastePercentage,
                amount: amountFormatter.format(report.tasteExpense),
                color: const PdfColor.fromInt(0xFF2979FF),
              ),
            ],
          ),
          if (report.coachMessage != null) ...[
            pw.SizedBox(height: 12),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEAF2FF),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                report.coachMessage!,
                style: const pw.TextStyle(
                  color: PdfColor.fromInt(0xFF174EA6),
                  fontSize: 10,
                ),
              ),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            'Detalle de movimientos',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          if (report.movements.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                'No se registraron movimientos en este período.',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 10,
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'Fecha',
                'Tipo',
                'Categoría',
                'Descripción',
                'Clasificación',
                'Monto',
              ],
              data: report.movements
                  .map(
                    (movement) => [
                      DateFormat('dd/MM/yyyy').format(movement.date),
                      movement.typeLabel,
                      movement.category,
                      movement.description,
                      movement.reflectionLabel,
                      amountFormatter.format(movement.amount),
                    ],
                  )
                  .toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFE8F5EC),
              ),
              headerStyle: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.1),
                1: const pw.FlexColumnWidth(0.8),
                2: const pw.FlexColumnWidth(1.1),
                3: const pw.FlexColumnWidth(1.7),
                4: const pw.FlexColumnWidth(1.1),
                5: const pw.FlexColumnWidth(1.2),
              },
            ),
          pw.SizedBox(height: 22),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generado el ${generatedAtFormatter.format(report.generatedAt)}',
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<File> createPdfFile({
    required FinancialReportData report,
    String filePrefix = 'reporte_financiero',
  }) async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);

    final timestamp = _buildTimestamp(report.generatedAt);
    final normalizedPrefix = _normalizeFilePrefix(filePrefix);
    final file = File(
      '${directory.path}${Platform.pathSeparator}${normalizedPrefix}_$timestamp.pdf',
    );

    await file.writeAsBytes(await buildPdf(report), flush: true);
    return file;
  }

  Future<ShareResult> sharePdf(File file) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Reporte financiero',
        text: 'Reporte generado desde Finanzas App Mobile',
      ),
    );
  }

  pw.Widget _buildMetric({
    required String label,
    required String value,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
            pw.SizedBox(height: 7),
            pw.FittedBox(
              fit: pw.BoxFit.scaleDown,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildClassification({
    required String label,
    required double percentage,
    required String amount,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color.shade(0.35)),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '${percentage.toStringAsFixed(0)}% $label',
              style: pw.TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              amount,
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  String _normalizeFilePrefix(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return normalized.isEmpty ? 'reporte_financiero' : normalized;
  }

  String _buildTimestamp(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${dateTime.year}'
        '${twoDigits(dateTime.month)}'
        '${twoDigits(dateTime.day)}_'
        '${twoDigits(dateTime.hour)}'
        '${twoDigits(dateTime.minute)}'
        '${twoDigits(dateTime.second)}';
  }
}
