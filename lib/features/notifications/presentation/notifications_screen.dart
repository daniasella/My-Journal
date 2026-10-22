import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Waktunya Menulis Jurnal!',
        'body': 'Bagikan ceritamu hari ini sebelum beristirahat malam.',
        'time': '30 menit yang lalu',
        'icon': Icons.menu_book_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'Target Kebiasaan Tercapai',
        'body': 'Kamu telah menyelesaikan kebiasaan Minum 2 Liter Air Putih hari ini. Hebat!',
        'time': '2 jam yang lalu',
        'icon': Icons.check_circle_rounded,
        'color': AppColors.success,
      },
      {
        'title': 'Pengingat Tugas',
        'body': 'Tugas "Review proposal proyek My Journal" dijadwalkan hari ini.',
        'time': '5 jam yang lalu',
        'icon': Icons.alarm_rounded,
        'color': AppColors.priorityMedium,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Tidak Ada Notifikasi',
              message: 'Semua kabar terbaru dan pengingat akan tampil di sini.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['body'] as String,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['time'] as String,
                              style: AppTextStyles.caption.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
