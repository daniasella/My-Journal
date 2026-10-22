import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/models/task.dart';
import '../domain/planner_controller.dart';
import '../../../core/utils/date_formatter.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? taskToEdit;

  const TaskFormScreen({super.key, this.taskToEdit});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late TaskPriority _selectedPriority;
  late String _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');

    if (task != null) {
      _selectedDate = task.scheduledAt;
      _selectedTime = TimeOfDay(hour: task.scheduledAt.hour, minute: task.scheduledAt.minute);
      _selectedPriority = task.priority;
      _selectedCategory = task.category ?? AppConstants.categoryLabels.first;
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
      _selectedPriority = TaskPriority.sedang;
      _selectedCategory = AppConstants.categoryLabels.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEdit = widget.taskToEdit != null;
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime?.hour ?? 9,
      _selectedTime?.minute ?? 0,
    );

    final task = Task(
      id: widget.taskToEdit?.id ?? '',
      userId: widget.taskToEdit?.userId ?? 'current_user',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      scheduledAt: scheduledDateTime,
      priority: _selectedPriority,
      status: widget.taskToEdit?.status ?? TaskStatus.belumSelesai,
      category: _selectedCategory,
      createdAt: widget.taskToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final controller = ref.read(plannerControllerProvider.notifier);
    final success = isEdit ? await controller.updateTask(task) : await controller.addTask(task);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Tugas berhasil diperbarui' : 'Tugas baru berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan tugas. Coba lagi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.taskToEdit != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Tugas' : 'Tambah Tugas Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _titleController,
                  label: 'Judul Tugas',
                  hintText: 'Contoh: Menyelesaikan laporan mingguan',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tugas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi (Opsional)',
                  hintText: 'Tambahkan catatan atau rincian tugas...',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date & Time pickers
                Text(
                  'Jadwal & Waktu',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  DateFormatter.formatShort(_selectedDate),
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _selectedTime != null
                                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Pilih Waktu',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Priority
                Text(
                  'Prioritas',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: TaskPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    Color activeColor;
                    switch (priority) {
                      case TaskPriority.tinggi:
                        activeColor = AppColors.priorityHigh;
                        break;
                      case TaskPriority.sedang:
                        activeColor = AppColors.priorityMedium;
                        break;
                      case TaskPriority.rendah:
                        activeColor = AppColors.priorityLow;
                        break;
                    }
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => setState(() => _selectedPriority = priority),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeColor.withValues(alpha: 0.15)
                                  : (isDark ? AppColors.surfaceDark : AppColors.surface),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(
                                color: isSelected ? activeColor : (isDark ? AppColors.borderDark : AppColors.border),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              priority.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected ? activeColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Category
                Text(
                  'Kategori',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categoryLabels.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: isEdit ? 'Simpan Perubahan' : 'Tambah Tugas',
                  icon: isEdit ? Icons.check : Icons.add_task,
                  isLoading: _isSubmitting,
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
