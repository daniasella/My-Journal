import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../shared/models/mood_entry.dart';
import '../domain/insight_controller.dart';
import '../../pdf_export/presentation/pdf_export_screen.dart';

class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(insightDataProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wawasan & Analisis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Ekspor Laporan PDF',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PdfExportScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Productivity Score Card
            _buildScoreCard(insight, isDark),
            const SizedBox(height: AppSpacing.lg),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Tugas Selesai',
                    value: '${insight.completedTasks}/${insight.totalTasks}',
                    subtitle: '${(insight.taskCompletionRate * 100).toInt()}% tuntas',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Kebiasaan Hari Ini',
                    value: '${insight.completedHabitsToday}/${insight.totalHabits}',
                    subtitle: 'rutinitas aktif',
                    icon: Icons.repeat_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Mood distribution Card
            _buildMoodAnalyticsCard(insight, isDark),
            const SizedBox(height: AppSpacing.lg),

            // Recommendations & Reflections
            Text(
              'Rekomendasi Pertumbuhan',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...insight.recommendations.map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          tip,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),

            // PDF Export Banner Button
            AppButton(
              label: 'Unduh & Bagikan Laporan PDF',
              icon: Icons.download_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PdfExportScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(InsightData insight, bool isDark) {
    return AppCard(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          // Circular gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: insight.productivityScore / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '${insight.productivityScore}',
                style: AppTextStyles.heading2.copyWith(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skor Produktivitas',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.productivityScore >= 80
                      ? 'Performa sangat prima! Terus jaga fokus dan energi positifmu.'
                      : 'Kinerja harian yang solid. Konsistensi kecil akan melipatgandakan hasilmu.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 22,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildMoodAnalyticsCard(InsightData insight, bool isDark) {
    final total = insight.moodCounts.values.fold(0, (a, b) => a + b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribusi Suasana Hati',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                insight.primaryMood,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...MoodType.values.map((mood) {
            final count = insight.moodCounts[mood] ?? 0;
            final ratio = total == 0 ? 0.0 : count / total;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    width: 60,
                    child: Text(mood.label, style: AppTextStyles.caption),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.background,
                        valueColor: AlwaysStoppedAnimation<Color>(mood.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('$count catatan', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
