import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/journal_entry.dart';
import '../../../shared/models/mood_entry.dart';
import '../domain/journal_controller.dart';
import 'journal_editor_screen.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalControllerProvider);
    final controller = ref.read(journalControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Jurnal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadEntries(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JournalEditorScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: const Text('Tulis Jurnal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.xs,
            ),
            child: AppTextField(
              hintText: 'Cari judul, cerita, atau tagar...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              onChanged: (val) => controller.setSearchQuery(val),
            ),
          ),

          // Mood filter row
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              scrollDirection: Axis.horizontal,
              itemCount: MoodType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final mood = MoodType.values[index];
                final isSelected = journalState.selectedMood == mood;
                return MoodChip(
                  mood: mood,
                  isSelected: isSelected,
                  onTap: () => controller.setMoodFilter(mood),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Entries List or Empty State
          Expanded(
            child: journalState.isLoading
                ? const LoadingView(message: 'Memuat jurnal...')
                : journalState.entries.isEmpty
                    ? EmptyState(
                        icon: Icons.menu_book_rounded,
                        title: 'Belum Ada Jurnal',
                        message: 'Catat setiap momen, pikiran, dan perasaanmu untuk mengenali dirimu lebih baik.',
                        actionLabel: 'Tulis Cerita Pertama',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const JournalEditorScreen(),
                            ),
                          );
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.loadEntries(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenPadding,
                            AppSpacing.xs,
                            AppSpacing.screenPadding,
                            80,
                          ),
                          itemCount: journalState.entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final entry = journalState.entries[index];
                            return _JournalItemCard(entry: entry);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _JournalItemCard extends StatelessWidget {
  final JournalEntry entry;

  const _JournalItemCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JournalDetailScreen(entry: entry),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatRelative(entry.createdAt),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (entry.mood != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.mood!.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      entry.mood!.label,
                      style: AppTextStyles.caption.copyWith(
                        color: entry.mood!.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            entry.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            entry.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (entry.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.category!,
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (entry.hasVoiceNote) ...[
                const Icon(Icons.mic, size: 14, color: AppColors.primary),
                const SizedBox(width: 2),
                Text('Audio', style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.primary)),
                const SizedBox(width: AppSpacing.xs),
              ],
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
