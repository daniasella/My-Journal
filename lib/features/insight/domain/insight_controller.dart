import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../planner/domain/planner_controller.dart';
import '../../journal/domain/journal_controller.dart';
import '../../tracker/domain/tracker_controller.dart';
import '../../../shared/models/mood_entry.dart';

class InsightData {
  final int totalTasks;
  final int completedTasks;
  final double taskCompletionRate;
  final int totalHabits;
  final int completedHabitsToday;
  final int totalJournals;
  final Map<MoodType, int> moodCounts;
  final int productivityScore; // 0-100
  final String primaryMood;
  final List<String> recommendations;

  const InsightData({
    required this.totalTasks,
    required this.completedTasks,
    required this.taskCompletionRate,
    required this.totalHabits,
    required this.completedHabitsToday,
    required this.totalJournals,
    required this.moodCounts,
    required this.productivityScore,
    required this.primaryMood,
    required this.recommendations,
  });
}

final insightDataProvider = Provider<InsightData>((ref) {
  final plannerState = ref.watch(plannerControllerProvider);
  final journalState = ref.watch(journalControllerProvider);
  final trackerState = ref.watch(trackerControllerProvider);

  final totalTasks = plannerState.tasks.length;
  final completedTasks = plannerState.tasks.where((t) => t.isCompleted).length;
  final taskRate = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  final totalHabits = trackerState.habits.length;
  final completedHabits = trackerState.completedHabitsTodayCount;
  final habitRate = totalHabits == 0 ? 0.0 : completedHabits / totalHabits;

  // Mood counts
  final Map<MoodType, int> moodMap = {
    MoodType.senang: 0,
    MoodType.tenang: 0,
    MoodType.biasa: 0,
    MoodType.sedih: 0,
    MoodType.marah: 0,
  };

  for (final j in journalState.entries) {
    if (j.mood != null) {
      moodMap[j.mood!] = (moodMap[j.mood!] ?? 0) + 1;
    }
  }

  // Find most frequent mood
  MoodType mostCommonMood = MoodType.senang;
  int maxCount = -1;
  moodMap.forEach((mood, count) {
    if (count > maxCount) {
      maxCount = count;
      mostCommonMood = mood;
    }
  });

  // Calculate composite productivity score: 60% tasks + 40% habits
  int score = ((taskRate * 60) + (habitRate * 40)).round();
  if (totalTasks == 0 && totalHabits == 0) score = 75; // Default encouraging initial score

  final recommendations = <String>[];
  if (taskRate >= 0.8) {
    recommendations.add('Luar biasa! Tingkat penyelesaian tugasmu sangat tinggi. Pertahankan ritme kerja ini.');
  } else {
    recommendations.add('Coba gunakan teknik time-blocking untuk menyelesaikan tugas berprioritas tinggi di pagi hari.');
  }

  if (completedHabits == totalHabits && totalHabits > 0) {
    recommendations.add('Semua kebiasaan harianmu tuntas hari ini! Konsistensi ini adalah kunci pertumbuhanmu.');
  } else {
    recommendations.add('Luangkan waktu 10 menit sebelum tidur untuk melengkapi rutinitas harian yang belum tuntas.');
  }

  recommendations.add('Menulis jurnal secara teratur terbukti menurunkan tingkat stres dan meningkatkan kejernihan berpikir.');

  return InsightData(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    taskCompletionRate: taskRate,
    totalHabits: totalHabits,
    completedHabitsToday: completedHabits,
    totalJournals: journalState.entries.length,
    moodCounts: moodMap,
    productivityScore: score.clamp(0, 100),
    primaryMood: '${mostCommonMood.emoji} ${mostCommonMood.label}',
    recommendations: recommendations,
  );
});
