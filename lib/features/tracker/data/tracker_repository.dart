import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/app_error.dart';
import '../../../shared/models/habit.dart';
import '../../../shared/models/goal.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/domain/auth_controller.dart';

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TrackerRepository(apiClient);
});

class TrackerRepository {
  final ApiClient _apiClient;
  ApiClient get apiClient => _apiClient;
  static const String _habitsKey = 'my_journal_cached_habits';
  static const String _habitLogsKey = 'my_journal_cached_habit_logs';
  static const String _goalsKey = 'my_journal_cached_goals';

  TrackerRepository(this._apiClient);

  // ================= HABITS =================
  Future<Result<List<Habit>>> getHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_habitsKey);
      List<Habit> habits = [];

      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        habits = decoded.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        habits = _generateInitialHabits();
        await _saveHabitsToLocal(habits);
      }

      return Success(habits);
    } catch (e) {
      return Failure(CacheError(e.toString()));
    }
  }

  Future<Result<Habit>> createHabit(Habit habit) async {
    try {
      final habitsResult = await getHabits();
      List<Habit> habits = [];
      if (habitsResult is Success<List<Habit>>) {
        habits = List.from(habitsResult.data);
      }

      final newHabit = habit.copyWith(
        id: habit.id.isEmpty ? const Uuid().v4() : habit.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      habits.add(newHabit);
      await _saveHabitsToLocal(habits);

      return Success(newHabit);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<Habit>> updateHabit(Habit habit) async {
    try {
      final habitsResult = await getHabits();
      if (habitsResult is! Success<List<Habit>>) {
        return Failure(const UnknownError('Gagal memuat kebiasaan'));
      }

      final habits = List<Habit>.from(habitsResult.data);
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index == -1) {
        return Failure(const NotFoundError('Kebiasaan tidak ditemukan'));
      }

      final updated = habit.copyWith(updatedAt: DateTime.now());
      habits[index] = updated;
      await _saveHabitsToLocal(habits);

      return Success(updated);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<bool>> deleteHabit(String id) async {
    try {
      final habitsResult = await getHabits();
      if (habitsResult is! Success<List<Habit>>) {
        return Failure(const UnknownError('Gagal memuat kebiasaan'));
      }

      final habits = List<Habit>.from(habitsResult.data);
      habits.removeWhere((h) => h.id == id);
      await _saveHabitsToLocal(habits);

      return const Success(true);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  // ================= HABIT LOGS =================
  Future<Result<List<HabitLog>>> getHabitLogs({String? date}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_habitLogsKey);
      List<HabitLog> logs = [];

      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        logs = decoded.map((e) => HabitLog.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        logs = _generateInitialHabitLogs();
        await _saveHabitLogsToLocal(logs);
      }

      if (date != null) {
        logs = logs.where((l) => l.logDate == date).toList();
      }

      return Success(logs);
    } catch (e) {
      return Failure(CacheError(e.toString()));
    }
  }

  Future<Result<HabitLog>> toggleHabitLog(String habitId, String date) async {
    try {
      final logsResult = await getHabitLogs();
      List<HabitLog> logs = [];
      if (logsResult is Success<List<HabitLog>>) {
        logs = List.from(logsResult.data);
      }

      final index = logs.indexWhere((l) => l.habitId == habitId && l.logDate == date);
      HabitLog updated;

      if (index != -1) {
        final existing = logs[index];
        updated = existing.copyWith(isCompleted: !existing.isCompleted);
        logs[index] = updated;
      } else {
        updated = HabitLog(
          id: const Uuid().v4(),
          habitId: habitId,
          userId: 'demo-user',
          localDate: date,
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
        logs.add(updated);
      }

      await _saveHabitLogsToLocal(logs);
      return Success(updated);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  // ================= GOALS =================
  Future<Result<List<Goal>>> getGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_goalsKey);
      List<Goal> goals = [];

      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        goals = decoded.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        goals = _generateInitialGoals();
        await _saveGoalsToLocal(goals);
      }

      return Success(goals);
    } catch (e) {
      return Failure(CacheError(e.toString()));
    }
  }

  Future<Result<Goal>> createGoal(Goal goal) async {
    try {
      final goalsResult = await getGoals();
      List<Goal> goals = [];
      if (goalsResult is Success<List<Goal>>) {
        goals = List.from(goalsResult.data);
      }

      final newGoal = goal.copyWith(
        id: goal.id.isEmpty ? const Uuid().v4() : goal.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      goals.add(newGoal);
      await _saveGoalsToLocal(goals);

      return Success(newGoal);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<Goal>> updateGoal(Goal goal) async {
    try {
      final goalsResult = await getGoals();
      if (goalsResult is! Success<List<Goal>>) {
        return Failure(const UnknownError('Gagal memuat tujuan'));
      }

      final goals = List<Goal>.from(goalsResult.data);
      final index = goals.indexWhere((g) => g.id == goal.id);
      if (index == -1) {
        return Failure(const NotFoundError('Tujuan tidak ditemukan'));
      }

      final updated = goal.copyWith(updatedAt: DateTime.now());
      goals[index] = updated;
      await _saveGoalsToLocal(goals);

      return Success(updated);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<bool>> deleteGoal(String id) async {
    try {
      final goalsResult = await getGoals();
      if (goalsResult is! Success<List<Goal>>) {
        return Failure(const UnknownError('Gagal memuat tujuan'));
      }

      final goals = List<Goal>.from(goalsResult.data);
      goals.removeWhere((g) => g.id == id);
      await _saveGoalsToLocal(goals);

      return const Success(true);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<Goal>> toggleMilestone(String goalId, String milestoneId) async {
    try {
      final goalsResult = await getGoals();
      if (goalsResult is! Success<List<Goal>>) {
        return Failure(const UnknownError('Gagal memuat tujuan'));
      }

      final goals = List<Goal>.from(goalsResult.data);
      final goalIndex = goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) {
        return Failure(const NotFoundError('Tujuan tidak ditemukan'));
      }

      final goal = goals[goalIndex];
      final milestones = List<GoalMilestone>.from(goal.milestones);
      final mIndex = milestones.indexWhere((m) => m.id == milestoneId);
      if (mIndex == -1) {
        return Failure(const NotFoundError('Milestone tidak ditemukan'));
      }

      final m = milestones[mIndex];
      milestones[mIndex] = GoalMilestone(
        id: m.id,
        goalId: m.goalId,
        title: m.title,
        isCompleted: !m.isCompleted,
        completedAt: !m.isCompleted ? DateTime.now() : null,
        sortOrder: m.sortOrder,
      );

      final updatedGoal = goal.copyWith(
        milestones: milestones,
        updatedAt: DateTime.now(),
      );

      goals[goalIndex] = updatedGoal;
      await _saveGoalsToLocal(goals);

      return Success(updatedGoal);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<void> _saveHabitsToLocal(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_habitsKey, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  Future<void> _saveHabitLogsToLocal(List<HabitLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_habitLogsKey, jsonEncode(logs.map((l) => l.toJson()).toList()));
  }

  Future<void> _saveGoalsToLocal(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsKey, jsonEncode(goals.map((g) => g.toJson()).toList()));
  }

  List<Habit> _generateInitialHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: 'habit-1',
        userId: 'demo-user',
        name: 'Minum 2 Liter Air Putih',
        description: 'Menjaga hidrasi tubuh sepanjang hari',
        frequency: HabitFrequency.setiapHari,
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        dailyTarget: 2.0,
        targetUnit: 'Liter',
        reminderEnabled: true,
        reminderTime: '08:00',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Habit(
        id: 'habit-2',
        userId: 'demo-user',
        name: 'Membaca Buku 15 Menit',
        description: 'Meningkatkan literasi dan wawasan',
        frequency: HabitFrequency.setiapHari,
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        dailyTarget: 15.0,
        targetUnit: 'Menit',
        reminderEnabled: true,
        reminderTime: '21:00',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Habit(
        id: 'habit-3',
        userId: 'demo-user',
        name: 'Jalan Kaki / Jogging',
        description: 'Aktivitas fisik ringan untuk kebugaran jantung',
        frequency: HabitFrequency.tigaKaliSeminggu,
        activeDays: [1, 3, 5],
        dailyTarget: 30.0,
        targetUnit: 'Menit',
        reminderEnabled: false,
        reminderTime: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<HabitLog> _generateInitialHabitLogs() {
    final now = DateTime.now();
    final todayStr = DateFormatter.toIsoDate(now);
    return [
      HabitLog(
        id: 'log-1',
        habitId: 'habit-1',
        userId: 'demo-user',
        localDate: todayStr,
        isCompleted: true,
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  List<Goal> _generateInitialGoals() {
    final now = DateTime.now();
    final targetDate = now.add(const Duration(days: 60));

    return [
      Goal(
        id: 'goal-1',
        userId: 'demo-user',
        title: 'Menyelesaikan Peluncuran Aplikasi My Journal',
        description: 'Rilis versi 1.0 dengan fitur jurnal, perencana kegiatan, dan sinkronisasi Neon',
        category: 'Pekerjaan',
        targetDate: targetDate,
        status: GoalStatus.sedangBerjalan,
        colorHex: '#3B82F6',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now,
        milestones: [
          GoalMilestone(
            id: 'm-1',
            goalId: 'goal-1',
            title: 'Desain UI/UX & Design Tokens Lengkap',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 7)),
            sortOrder: 1,
          ),
          GoalMilestone(
            id: 'm-2',
            goalId: 'goal-1',
            title: 'Implementasi Fitur Planner, Journal, & Tracker',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 1)),
            sortOrder: 2,
          ),
          GoalMilestone(
            id: 'm-3',
            goalId: 'goal-1',
            title: 'Uji Coba Pengguna & Ekspor PDF',
            isCompleted: false,
            completedAt: null,
            sortOrder: 3,
          ),
        ],
      ),
      Goal(
        id: 'goal-2',
        userId: 'demo-user',
        title: 'Membaca 6 Buku Tahun Ini',
        description: 'Membangun kebiasaan membaca buku non-fiksi secara rutin',
        category: 'Pendidikan',
        targetDate: now.add(const Duration(days: 180)),
        status: GoalStatus.sedangBerjalan,
        colorHex: '#10B981',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        milestones: [
          GoalMilestone(
            id: 'm-201',
            goalId: 'goal-2',
            title: 'Buku 1: Atomic Habits',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 10)),
            sortOrder: 1,
          ),
          GoalMilestone(
            id: 'm-202',
            goalId: 'goal-2',
            title: 'Buku 2: Deep Work',
            isCompleted: false,
            completedAt: null,
            sortOrder: 2,
          ),
        ],
      ),
    ];
  }
}
