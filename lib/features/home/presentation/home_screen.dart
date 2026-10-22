import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/mood_entry.dart';
import '../../auth/domain/auth_controller.dart';
import '../../planner/domain/planner_controller.dart';
import '../../journal/domain/journal_controller.dart';
import '../../journal/presentation/journal_editor_screen.dart';
import '../../journal/presentation/journal_detail_screen.dart';
import '../../tracker/domain/tracker_controller.dart';
import '../../planner/presentation/task_form_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final plannerState = ref.watch(plannerControllerProvider);
    final journalState = ref.watch(journalControllerProvider);
    final trackerState = ref.watch(trackerControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userName = user?.displayName.split(' ').first ?? 'Teman';
    final greeting = DateFormatter.formatGreeting();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.screenPadding,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  userName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(plannerControllerProvider.notifier).loadTasks();
          ref.read(journalControllerProvider.notifier).loadEntries();
          ref.read(trackerControllerProvider.notifier).loadAll();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Banner
              Text(
                DateFormatter.formatFull(DateTime.now()),
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Hero Summary Card
              _buildHeroSummaryCard(plannerState, trackerState, isDark),
              const SizedBox(height: AppSpacing.lg),

              // Mood Quick Check-in
              _buildQuickMoodSection(context, isDark),
              const SizedBox(height: AppSpacing.lg),

              // Today's Priority Tasks
              _buildTasksSection(context, ref, plannerState, isDark),
              const SizedBox(height: AppSpacing.lg),

              // Today's Habits
              _buildHabitsSection(context, ref, trackerState, isDark),
              const SizedBox(height: AppSpacing.lg),

              // Recent Journal
              _buildRecentJournalSection(context, journalState, isDark),
              const SizedBox(height: AppSpacing.lg),

              // Daily Motivation Card
              _buildMotivationCard(isDark),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSummaryCard(PlannerState planner, TrackerState tracker, bool isDark) {
    return AppCard(
      gradient: const LinearGradient(
        colors: [AppColors.primary, Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Hari Ini',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${planner.completedCount}/${planner.totalCount}',
                      style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 28),
                    ),
                    Text('Tugas Selesai', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tracker.completedHabitsTodayCount}/${tracker.habits.length}',
                      style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 28),
                    ),
                    Text('Kebiasaan Aktif', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMoodSection(BuildContext context, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bagaimana suasana hatimu hari ini?',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodType.values.map((mood) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JournalEditorScreen(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mood.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(height: 4),
                    Text(mood.label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, WidgetRef ref, PlannerState planner, bool isDark) {
    final todayTasks = planner.filteredTasks.take(3).toList();
    final controller = ref.read(plannerControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Utama',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(1); // Go to Planner tab
                }
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        if (todayTasks.isEmpty)
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.done_all_rounded, color: AppColors.success),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Semua tugas hari ini sudah beres atau belum dijadwalkan.', style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          )
        else
          ...todayTasks.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TaskFormScreen(taskToEdit: t)),
                  );
                },
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleTask(t.id),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: t.isCompleted ? AppColors.success : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: t.isCompleted ? AppColors.success : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: t.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        t.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                          color: t.isCompleted ? AppColors.textSecondary : null,
                        ),
                      ),
                    ),
                    PriorityChip(priority: t.priority),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHabitsSection(BuildContext context, WidgetRef ref, TrackerState tracker, bool isDark) {
    final habits = tracker.habits.take(3).toList();
    final controller = ref.read(trackerControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rutinitas Harian',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(3); // Go to Tracker tab
                }
              },
              child: const Text('Kelola'),
            ),
          ],
        ),
        if (habits.isEmpty)
          AppCard(
            child: Text('Belum ada kebiasaan harian. Mulai bangun rutinitasmu sekarang!', style: AppTextStyles.bodySmall),
          )
        else
          ...habits.map((h) {
            final isDone = tracker.isHabitCompletedToday(h.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleHabitToday(h.id),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.success : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone ? AppColors.success : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        h.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Text(
                      h.frequency.label,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRecentJournalSection(BuildContext context, JournalState journal, bool isDark) {
    final latest = journal.entries.isNotEmpty ? journal.entries.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catatan Jurnal Terakhir',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(2); // Go to Journal tab
                }
              },
              child: const Text('Buka Jurnal'),
            ),
          ],
        ),
        if (latest != null)
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => JournalDetailScreen(entry: latest)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(latest.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    if (latest.mood != null) Text(latest.mood!.emoji, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  latest.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          AppCard(
            child: Text('Belum ada catatan jurnal. Tulis refleksi pertamamu hari ini!', style: AppTextStyles.bodySmall),
          ),
      ],
    );
  }

  Widget _buildMotivationCard(bool isDark) {
    return AppCard(
      backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.success, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"Kita tidak memutuskan masa depan kita. Kita memutuskan kebiasaan kita, dan kebiasaan kitalah yang memutuskan masa depan kita."',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— F.M. Alexander',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
