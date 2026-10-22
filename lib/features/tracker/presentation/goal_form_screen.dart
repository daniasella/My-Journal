import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/goal.dart';
import '../domain/tracker_controller.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  final Goal? goalToEdit;

  const GoalFormScreen({super.key, this.goalToEdit});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _milestoneInputController;

  late String _category;
  late DateTime _targetDate;
  late List<GoalMilestone> _milestones;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goalToEdit;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _milestoneInputController = TextEditingController();

    _category = g?.category ?? AppConstants.categoryLabels.first;
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    _milestones = g != null ? List.from(g.milestones) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _milestoneInputController.dispose();
    super.dispose();
  }

  void _addMilestone() {
    final text = _milestoneInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _milestones.add(
          GoalMilestone(
            id: const Uuid().v4(),
            goalId: widget.goalToEdit?.id ?? '',
            title: text,
            isCompleted: false,
            sortOrder: _milestones.length + 1,
          ),
        );
        _milestoneInputController.clear();
      });
    }
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones.removeAt(index);
    });
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEdit = widget.goalToEdit != null;
    final now = DateTime.now();

    final goal = Goal(
      id: widget.goalToEdit?.id ?? '',
      userId: widget.goalToEdit?.userId ?? 'demo-user',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _category,
      targetDate: _targetDate,
      status: widget.goalToEdit?.status ?? GoalStatus.sedangBerjalan,
      colorHex: '#3B82F6',
      createdAt: widget.goalToEdit?.createdAt ?? now,
      updatedAt: now,
      milestones: _milestones,
    );

    final controller = ref.read(trackerControllerProvider.notifier);
    final success = isEdit ? await controller.updateGoal(goal) : await controller.addGoal(goal);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Tujuan berhasil diperbarui' : 'Tujuan baru berhasil dibuat'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan tujuan'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goalToEdit != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Tujuan' : 'Tambah Tujuan Baru'),
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
                  label: 'Nama / Target Tujuan',
                  hintText: 'Misal: Mahir Flutter & Bangun Portofolio Neon',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama tujuan tidak boleh kosong' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descController,
                  label: 'Deskripsi Rencana',
                  hintText: 'Tuliskan strategi atau motivasi di balik tujuan ini...',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Target Date
                Text('Target Selesai', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: _pickTargetDate,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(DateFormatter.formatShort(_targetDate), style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Milestones
                Text('Tahapan / Milestones', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _milestoneInputController,
                        hintText: 'Tambah tahapan (contoh: Bab 1)',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addMilestone(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _addMilestone,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                if (_milestones.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _milestones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final m = _milestones[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.card,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(m.title, style: AppTextStyles.bodySmall)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                              onPressed: () => _removeMilestone(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: isEdit ? 'Simpan Perubahan' : 'Mulai Tujuan',
                  icon: Icons.rocket_launch_outlined,
                  isLoading: _isSubmitting,
                  onPressed: _saveGoal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
