import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MovementExportService {
  Future<String> exportCsv({
    required String filePrefix,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final csvBuffer = StringBuffer()
      ..writeln(headers.map(_escapeCsvValue).join(','));

    for (final row in rows) {
      csvBuffer.writeln(row.map(_escapeCsvValue).join(','));
    }

    final directory = await _resolveOutputDirectory();
    final timestamp = _buildTimestamp(DateTime.now());
    final file = File(
      '${directory.path}${Platform.pathSeparator}${filePrefix}_$timestamp.csv',
    );

    await file.writeAsString(csvBuffer.toString(), flush: true);
    return file.path;
  }

  Future<Directory> _resolveOutputDirectory() async {
    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      await downloadsDirectory.create(recursive: true);
      return downloadsDirectory;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    await documentsDirectory.create(recursive: true);
    return documentsDirectory;
  }

  String _buildTimestamp(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${dateTime.year}${two(dateTime.month)}${two(dateTime.day)}_${two(dateTime.hour)}${two(dateTime.minute)}${two(dateTime.second)}';
  }

  String _escapeCsvValue(String value) {
    final sanitizedValue = value.replaceAll('"', '""');
    return '"$sanitizedValue"';
  }
}
