import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/models/user_profile.dart';
import '../../auth/domain/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final updated = UserProfile(
        id: currentUser.id,
        authUserId: currentUser.authUserId,
        displayName: _nameController.text.trim(),
        email: currentUser.email,
        bio: _bioController.text.trim(),
        photoUrl: currentUser.photoUrl,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
      );

      ref.read(authControllerProvider.notifier).updateProfile(updated);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Profil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _bioController,
                  label: 'Bio / Kutipan Pribadi',
                  hintText: 'Tuliskan sedikit tentang dirimu atau prinsip hidupmu...',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Simpan Perubahan',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
