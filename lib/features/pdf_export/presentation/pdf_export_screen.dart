import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_colors.dart';
import '../../planner/domain/planner_controller.dart';
import '../../journal/domain/journal_controller.dart';
import '../../auth/domain/auth_controller.dart';
import '../data/pdf_generator_service.dart';

class PdfExportScreen extends ConsumerWidget {
  const PdfExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannerState = ref.watch(plannerControllerProvider);
    final journalState = ref.watch(journalControllerProvider);
    final user = ref.watch(currentUserProvider);

    final userName = user?.displayName ?? 'Pengguna My Journal';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekspor Laporan PDF'),
      ),
      body: PdfPreview(
        build: (format) => PdfGeneratorService.generateJournalReport(
          userName: userName,
          entries: journalState.entries,
          tasks: plannerState.tasks,
        ),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: 'My_Journal_Report.pdf',
        previewPageMargin: const EdgeInsets.all(16),
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
