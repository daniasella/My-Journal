import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/models/habit.dart';
import '../domain/tracker_controller.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const HabitFormScreen({super.key, this.habitToEdit});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  late HabitFrequency _frequency;
  late List<int> _activeDays;
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _descController = TextEditingController(text: h?.description ?? '');
    _targetController = TextEditingController(text: h?.dailyTarget?.toInt().toString() ?? '1');
    _unitController = TextEditingController(text: h?.targetUnit ?? 'kali');

    _frequency = h?.frequency ?? HabitFrequency.setiapHari;
    _activeDays = h?.activeDays != null ? List.from(h!.activeDays) : [1, 2, 3, 4, 5, 6, 7];
    _reminderEnabled = h?.reminderEnabled ?? true;

    if (h?.reminderTime != null) {
      final parts = h!.reminderTime!.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEdit = widget.habitToEdit != null;
    final timeStr = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

    final habit = Habit(
      id: widget.habitToEdit?.id ?? '',
      userId: widget.habitToEdit?.userId ?? 'demo-user',
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      frequency: _frequency,
      activeDays: _activeDays,
      dailyTarget: double.tryParse(_targetController.text) ?? 1.0,
      targetUnit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderEnabled ? timeStr : null,
      isActive: true,
      createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final controller = ref.read(trackerControllerProvider.notifier);
    final success = isEdit ? await controller.updateHabit(habit) : await controller.addHabit(habit);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Kebiasaan berhasil diperbarui' : 'Kebiasaan baru berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan kebiasaan'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitToEdit != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Kebiasaan' : 'Tambah Kebiasaan Baru'),
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
                  controller: _nameController,
                  label: 'Nama Kebiasaan',
                  hintText: 'Contoh: Minum 2 liter air, Meditasi, Membaca buku',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama kebiasaan wajib diisi' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descController,
                  label: 'Deskripsi / Alasan (Opsional)',
                  hintText: 'Mengapa kebiasaan ini penting untukmu?',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Frequency
                Text('Frekuensi', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitFrequency.values.map((f) {
                    final isSelected = _frequency == f;
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _frequency = f);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Target & Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: _targetController,
                        label: 'Target Harian',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        controller: _unitController,
                        label: 'Satuan',
                        hintText: 'kali / menit / liter / halaman',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Reminder switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Pengingat Harian',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _reminderEnabled
                        ? 'Notifikasi pukul ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
                        : 'Pengingat dimatikan',
                    style: AppTextStyles.caption,
                  ),
                  value: _reminderEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _reminderEnabled = val);
                  },
                ),
                if (_reminderEnabled) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.access_time_rounded),
                    label: Text(
                      'Ubah Jam: ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    ),
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _reminderTime);
                      if (picked != null) setState(() => _reminderTime = picked);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: isEdit ? 'Simpan Perubahan' : 'Buat Kebiasaan',
                  icon: isEdit ? Icons.check : Icons.add_circle_outline,
                  isLoading: _isSubmitting,
                  onPressed: _saveHabit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
