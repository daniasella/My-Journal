import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/journal_entry.dart';
import '../../../shared/models/mood_entry.dart';
import '../domain/journal_controller.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  final JournalEntry? entryToEdit;

  const JournalEditorScreen({super.key, this.entryToEdit});

  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;

  MoodType? _selectedMood;
  String? _selectedCategory;
  List<String> _tags = [];
  bool _isSubmitting = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  bool _hasVoiceNote = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entryToEdit;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _tagInputController = TextEditingController();

    if (entry != null) {
      _selectedMood = entry.mood;
      _selectedCategory = entry.category;
      _tags = List.from(entry.tags);
      _hasVoiceNote = entry.hasVoiceNote;
    } else {
      _selectedMood = MoodType.senang;
      _selectedCategory = AppConstants.categoryLabels.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _tagInputController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEdit = widget.entryToEdit != null;
    final now = DateTime.now();

    final entry = JournalEntry(
      id: widget.entryToEdit?.id ?? '',
      userId: widget.entryToEdit?.userId ?? 'demo-user',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      entryDate: widget.entryToEdit?.entryDate ?? DateFormatter.toIsoDate(now),
      mood: _selectedMood,
      category: _selectedCategory,
      tags: _tags,
      photoUrls: widget.entryToEdit?.photoUrls ?? [],
      voiceNoteUrl: _hasVoiceNote ? 'mock_voice_recording.m4a' : null,
      voiceNoteDurationSeconds: _hasVoiceNote ? (_recordSeconds > 0 ? _recordSeconds.toDouble() : 45.0) : null,
      voiceNoteObjectKey: null,
      createdAt: widget.entryToEdit?.createdAt ?? now,
      updatedAt: now,
    );

    final controller = ref.read(journalControllerProvider.notifier);
    final success = isEdit ? await controller.updateEntry(entry) : await controller.addEntry(entry);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Jurnal berhasil diperbarui' : 'Jurnal berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan jurnal. Coba lagi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entryToEdit != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Jurnal' : 'Tulis Jurnal Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood Selection
                Text(
                  'Bagaimana perasaanmu saat ini?',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MoodType.values.map((mood) {
                    final isSelected = _selectedMood == mood;
                    return MoodChip(
                      mood: mood,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                AppTextField(
                  controller: _titleController,
                  label: 'Judul Jurnal',
                  hintText: 'Misal: Hari yang penuh kejutan menyenangkan',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul jurnal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Category
                Text(
                  'Kategori',
                  style: AppTextStyles.label.copyWith(
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
                const SizedBox(height: AppSpacing.md),

                // Content
                AppTextField(
                  controller: _contentController,
                  label: 'Isi Cerita & Refleksi',
                  hintText: 'Tuliskan apa yang kamu rasakan, pengalaman berharga, atau hal yang kamu syukuri hari ini...',
                  minLines: 6,
                  maxLines: 12,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Isi jurnal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Voice Recording section
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _isRecording ? AppColors.error : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isRecording ? Icons.stop : (_hasVoiceNote ? Icons.check : Icons.mic_rounded),
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isRecording) {
                                _isRecording = false;
                                _hasVoiceNote = true;
                              } else {
                                _isRecording = true;
                                _recordSeconds = 30;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isRecording
                                  ? 'Merekam audio...'
                                  : _hasVoiceNote
                                      ? 'Rekaman audio terpasang'
                                      : 'Rekam Catatan Suara',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _isRecording
                                  ? 'Tekan tombol stop untuk menyelesaikan'
                                  : 'Ceritakan harimu secara lisan',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (_hasVoiceNote && !_isRecording)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            setState(() {
                              _hasVoiceNote = false;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tags Section
                Text(
                  'Tagar (#)',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _tagInputController,
                        hintText: 'Tambah tagar (contoh: Refleksi)',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _addTag,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: isEdit ? 'Simpan Perubahan' : 'Terbitkan Jurnal',
                  icon: Icons.check_circle_outline,
                  isLoading: _isSubmitting,
                  onPressed: _saveEntry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
