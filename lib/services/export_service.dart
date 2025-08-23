import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportCSV(List<Map<String, dynamic>> data) async {
    try {
      final rows = <List<dynamic>>[];

      // Header row
      rows.add(data.isNotEmpty ? data.first.keys.toList() : []);

      // Data rows
      for (final row in data) {
        rows.add(row.values.toList());
      }

      String csvData = const ListToCsvConverter().convert(rows);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/medicine_data.csv');
      await file.writeAsString(csvData);

      await Share.shareXFiles([XFile(file.path)], text: 'Medicine Data (CSV)');
    } catch (e) {
      throw Exception('CSV export failed: $e');
    }
  }

  /// Export medicine data as PDF
  static Future<void> exportPDF(List<Map<String, dynamic>> data) async {
    try {
      final pdf = pw.Document();

      // Add content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Medicine History',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: data.isNotEmpty ? data.first.keys.toList() : [],
                  data: data.map((row) => row.values.toList()).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  border: pw.TableBorder.all(width: 0.5),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/medicine_data.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Medicine Data (PDF)');
    } catch (e) {
      throw Exception('PDF export failed: $e');
    }
  }
}

class FirebaseDataService {
  static Future<List<Map<String, dynamic>>> fetchMedicines(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
