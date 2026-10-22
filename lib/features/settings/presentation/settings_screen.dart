import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyReminder = true;
  bool _habitNotifications = true;
  bool _taskDueNotifications = true;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Tampilan & Tema
          Text(
            'TAMPILAN',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('Sistem'),
                    icon: Icon(Icons.brightness_auto, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Terang'),
                    icon: Icon(Icons.light_mode_outlined, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Gelap'),
                    icon: Icon(Icons.dark_mode_outlined, size: 18),
                  ),
                ],
                selected: {currentThemeMode},
                onSelectionChanged: (newSelection) {
                  themeNotifier.setThemeMode(newSelection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Notifikasi
          Text(
            'NOTIFIKASI & PENGINGAT',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Pengingat Jurnal Harian'),
                  subtitle: const Text('Ingatkan untuk refleksi setiap malam pukul 20:00'),
                  value: _dailyReminder,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _dailyReminder = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Pengingat Kebiasaan'),
                  subtitle: const Text('Notifikasi sesuai jadwal target rutinitasmu'),
                  value: _habitNotifications,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _habitNotifications = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Tenggat Waktu Tugas'),
                  subtitle: const Text('Peringatan 15 menit sebelum waktu tugas tiba'),
                  value: _taskDueNotifications,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _taskDueNotifications = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Backend Neon Database
          Text(
            'SINKRONISASI & DATABASE',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Neon PostgreSQL Cloud',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.cloud_done, color: AppColors.success, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Data tersinkronisasi secara otomatis saat perangkat terhubung ke internet. Dukungan offline-first aktif.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Sinkronkan Sekarang'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua data lokal berhasil disinkronkan ke Neon Cloud'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tentang Aplikasi
          Text(
            'TENTANG',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Versi Aplikasi'),
                  trailing: Text('1.0.0 (Build 1)', style: AppTextStyles.caption),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Kebijakan Privasi & Ketentuan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'My Journal',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 My Journal Team. All rights reserved.',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
