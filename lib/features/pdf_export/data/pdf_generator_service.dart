import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/journal_entry.dart';
import '../../../shared/models/task.dart';

class PdfGeneratorService {
  PdfGeneratorService._();

  static Future<Uint8List> generateJournalReport({
    required String userName,
    required List<JournalEntry> entries,
    required List<Task> tasks,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final dateStr = DateFormatter.formatFull(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MY JOURNAL',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo700,
                        ),
                      ),
                      pw.Text(
                        'Laporan Catatan & Produktivitas Pribadi',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Pengguna: $userName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Tanggal Cetak: $dateStr', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Section 1: Ringkasan Tugas
            pw.Text(
              'Ringkasan Tugas & Aktivitas',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Tugas', 'Kategori', 'Prioritas', 'Status'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo600),
              data: tasks.asMap().entries.map((entry) {
                final i = entry.key + 1;
                final t = entry.value;
                return [
                  '$i',
                  t.title,
                  t.category,
                  t.priority.name.toUpperCase(),
                  t.isCompleted ? 'SELESAI' : 'BELUM',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 24),

            // Section 2: Jurnal Terpilih
            pw.Text(
              'Catatan Refleksi & Jurnal Harian',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
            ),
            pw.SizedBox(height: 8),
            ...entries.map((j) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          j.title,
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${j.entryDate} | Mood: ${j.mood?.label ?? "Netral"}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      j.content,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              );
            }),

            // Footer
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.Center(
              child: pw.Text(
                'My Journal App — Plan Your Day. Capture Your Story. Grow Every Day.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
