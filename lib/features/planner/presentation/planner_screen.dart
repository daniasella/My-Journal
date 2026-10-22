import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../shared/models/task.dart';
import '../domain/planner_controller.dart';
import 'task_form_screen.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannerState = ref.watch(plannerControllerProvider);
    final controller = ref.read(plannerControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perencana Kegiatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadTasks(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TaskFormScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tugas Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Horizontal Date Strip
          _buildHorizontalCalendar(context, ref, plannerState.selectedDate),

          // Progress and Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.sm,
            ),
            child: _buildProgressCard(plannerState, isDark),
          ),

          // Categories bar
          _buildCategoryFilter(ref, plannerState),

          const SizedBox(height: AppSpacing.xs),

          // Task list or empty state
          Expanded(
            child: plannerState.isLoading
                ? const LoadingView(message: 'Memuat tugas...')
                : plannerState.filteredTasks.isEmpty
                    ? EmptyState(
                        icon: Icons.checklist_rounded,
                        title: 'Tidak Ada Tugas',
                        message: 'Tidak ada tugas yang dijadwalkan untuk tanggal ini. Mulai dengan membuat tugas baru!',
                        actionLabel: 'Tambah Tugas',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TaskFormScreen(),
                            ),
                          );
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.loadTasks(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenPadding,
                            AppSpacing.xs,
                            AppSpacing.screenPadding,
                            80, // bottom padding for FAB
                          ),
                          itemCount: plannerState.filteredTasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final task = plannerState.filteredTasks[index];
                            return _TaskItem(task: task);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final now = DateTime.now();
    // Generate dates around selected date (-3 to +10 days)
    final days = List.generate(14, (i) {
      return now.add(Duration(days: i - 2));
    });

    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return GestureDetector(
            onTap: () {
              ref.read(plannerControllerProvider.notifier).selectDate(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                        ? AppColors.primaryLight
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayNameShort(date.weekday),
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.heading3.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayNameShort(int weekday) {
    switch (weekday) {
      case 1: return 'Sen';
      case 2: return 'Sel';
      case 3: return 'Rab';
      case 4: return 'Kam';
      case 5: return 'Jum';
      case 6: return 'Sab';
      case 7: return 'Min';
      default: return '';
    }
  }

  Widget _buildProgressCard(PlannerState state, bool isDark) {
    final percent = (state.completionProgress * 100).toInt();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres Hari Ini',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${state.completedCount}/${state.totalCount} Selesai ($percent%)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: state.completionProgress,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, PlannerState state) {
    final categories = ['Semua', ...AppConstants.categoryLabels];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isAll = cat == 'Semua';
          final isSelected = isAll
              ? state.selectedCategory == null
              : state.selectedCategory == cat;

          return CategoryChip(
            category: cat,
            isSelected: isSelected,
            onTap: () {
              ref.read(plannerControllerProvider.notifier).selectCategory(isAll ? null : cat);
            },
          );
        },
      ),
    );
  }
}

class _TaskItem extends ConsumerWidget {
  final Task task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(plannerControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Tugas'),
            content: Text('Yakin ingin menghapus "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        controller.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas telah dihapus')),
        );
      },
      child: AppCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(taskToEdit: task),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => controller.toggleTask(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2, right: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: task.isCompleted ? AppColors.success : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      PriorityChip(priority: task.priority),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        task.dueTime,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.category ?? 'Harian',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
