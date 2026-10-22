import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../domain/tracker_controller.dart';
import 'habit_form_screen.dart';
import 'goal_form_screen.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackerControllerProvider);
    final controller = ref.read(trackerControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelacak Rutinitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (state.activeTab == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HabitFormScreen()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GoalFormScreen()),
            );
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          state.activeTab == 0 ? 'Kebiasaan Baru' : 'Tujuan Baru',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Segmented Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.sm,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Kebiasaan Harian (${state.habits.length})',
                      isSelected: state.activeTab == 0,
                      onTap: () => controller.setActiveTab(0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Tujuan & Rencana (${state.goals.length})',
                      isSelected: state.activeTab == 1,
                      onTap: () => controller.setActiveTab(1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: state.isLoading
                ? const LoadingView(message: 'Memuat data pelacak...')
                : state.activeTab == 0
                    ? _buildHabitsList(context, ref, state, isDark)
                    : _buildGoalsList(context, ref, state, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context, WidgetRef ref, TrackerState state, bool isDark) {
    if (state.habits.isEmpty) {
      return EmptyState(
        icon: Icons.repeat_rounded,
        title: 'Belum Ada Kebiasaan',
        message: 'Bangun rutinitas positif setiap hari. Konsistensi kecil menghasilkan perubahan besar.',
        actionLabel: 'Buat Kebiasaan',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HabitFormScreen()),
          );
        },
      );
    }

    final controller = ref.read(trackerControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xs,
        AppSpacing.screenPadding,
        80,
      ),
      children: [
        // Summary Header Card
        AppCard(
          backgroundColor: AppColors.primaryLight,
          borderColor: AppColors.primary.withValues(alpha: 0.2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencapaian Hari Ini',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${state.completedHabitsTodayCount} dari ${state.habits.length} kebiasaan sudah terselesaikan!',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Habit Cards
        ...state.habits.map((habit) {
          final isCompleted = state.isHabitCompletedToday(habit.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: Row(
                children: [
                  // Tap to toggle
                  GestureDetector(
                    onTap: () => controller.toggleHabitToday(habit.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.success : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? AppColors.success : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 20, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Habit details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                          ),
                        ),
                        if (habit.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            habit.description!,
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.background,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                habit.frequency.label,
                                style: AppTextStyles.caption.copyWith(fontSize: 10),
                              ),
                            ),
                            if (habit.reminderTime != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Icon(Icons.alarm, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 2),
                              Text(
                                habit.reminderTime!,
                                style: AppTextStyles.caption.copyWith(fontSize: 10),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                    onSelected: (val) {
                      if (val == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HabitFormScreen(habitToEdit: habit),
                          ),
                        );
                      } else if (val == 'delete') {
                        controller.deleteHabit(habit.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGoalsList(BuildContext context, WidgetRef ref, TrackerState state, bool isDark) {
    if (state.goals.isEmpty) {
      return EmptyState(
        icon: Icons.flag_rounded,
        title: 'Belum Ada Target',
        message: 'Tentukan tujuan jangka panjangmu dan pecah menjadi tahapan-tahapan yang dapat dicapai.',
        actionLabel: 'Buat Target Pertama',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GoalFormScreen()),
          );
        },
      );
    }

    final controller = ref.read(trackerControllerProvider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xs,
        AppSpacing.screenPadding,
        80,
      ),
      itemCount: state.goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final goal = state.goals[index];
        final completedMilestones = goal.milestones.where((m) => m.isCompleted).length;
        final totalMilestones = goal.milestones.length;
        final progress = totalMilestones == 0 ? 0.0 : completedMilestones / totalMilestones;
        final percent = (progress * 100).toInt();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      goal.category ?? 'Target',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                    onSelected: (val) {
                      if (val == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GoalFormScreen(goalToEdit: goal),
                          ),
                        );
                      } else if (val == 'delete') {
                        controller.deleteGoal(goal.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                goal.title,
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              if (goal.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  goal.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progres', style: AppTextStyles.caption),
                  Text('$percent% ($completedMilestones/$totalMilestones)', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

              // Milestones list
              if (goal.milestones.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                ...goal.milestones.map((m) {
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      m.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                        color: m.isCompleted ? AppColors.textSecondary : null,
                      ),
                    ),
                    value: m.isCompleted,
                    activeColor: AppColors.primary,
                    onChanged: (_) {
                      controller.toggleMilestone(goal.id, m.id);
                    },
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
