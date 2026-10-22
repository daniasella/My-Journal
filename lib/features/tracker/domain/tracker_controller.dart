import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/habit.dart';
import '../../../shared/models/goal.dart';
import '../data/tracker_repository.dart';

class TrackerState {
  final List<Habit> habits;
  final List<HabitLog> todayLogs;
  final List<Goal> goals;
  final bool isLoading;
  final String? errorMessage;
  final int activeTab; // 0 = Habits, 1 = Goals

  TrackerState({
    this.habits = const [],
    this.todayLogs = const [],
    this.goals = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeTab = 0,
  });

  TrackerState copyWith({
    List<Habit>? habits,
    List<HabitLog>? todayLogs,
    List<Goal>? goals,
    bool? isLoading,
    String? errorMessage,
    int? activeTab,
  }) {
    return TrackerState(
      habits: habits ?? this.habits,
      todayLogs: todayLogs ?? this.todayLogs,
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  bool isHabitCompletedToday(String habitId) {
    return todayLogs.any((l) => l.habitId == habitId && l.isCompleted);
  }

  int get completedHabitsTodayCount {
    return habits.where((h) => isHabitCompletedToday(h.id)).length;
  }
}

class TrackerNotifier extends StateNotifier<TrackerState> {
  final TrackerRepository _repository;

  TrackerNotifier(this._repository) : super(TrackerState(isLoading: true)) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final todayStr = DateFormatter.toIsoDate(DateTime.now());

    final habitsResult = await _repository.getHabits();
    final logsResult = await _repository.getHabitLogs(date: todayStr);
    final goalsResult = await _repository.getGoals();

    List<Habit> habits = [];
    List<HabitLog> logs = [];
    List<Goal> goals = [];

    if (habitsResult is Success<List<Habit>>) habits = habitsResult.data;
    if (logsResult is Success<List<HabitLog>>) logs = logsResult.data;
    if (goalsResult is Success<List<Goal>>) goals = goalsResult.data;

    state = state.copyWith(
      habits: habits,
      todayLogs: logs,
      goals: goals,
      isLoading: false,
    );
  }

  void setActiveTab(int tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<void> toggleHabitToday(String habitId) async {
    final todayStr = DateFormatter.toIsoDate(DateTime.now());
    final result = await _repository.toggleHabitLog(habitId, todayStr);
    if (result is Success<HabitLog>) {
      // Reload logs
      final logsResult = await _repository.getHabitLogs(date: todayStr);
      if (logsResult is Success<List<HabitLog>>) {
        state = state.copyWith(todayLogs: logsResult.data);
      }
    }
  }

  Future<bool> addHabit(Habit habit) async {
    final result = await _repository.createHabit(habit);
    if (result is Success<Habit>) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> updateHabit(Habit habit) async {
    final result = await _repository.updateHabit(habit);
    if (result is Success<Habit>) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> deleteHabit(String id) async {
    final result = await _repository.deleteHabit(id);
    if (result is Success<bool>) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final result = await _repository.toggleMilestone(goalId, milestoneId);
    if (result is Success<Goal>) {
      await loadAll();
    }
  }

  Future<bool> addGoal(Goal goal) async {
    final result = await _repository.createGoal(goal);
    if (result is Success<Goal>) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> updateGoal(Goal goal) async {
    final result = await _repository.updateGoal(goal);
    if (result is Success<Goal>) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> deleteGoal(String id) async {
    final result = await _repository.deleteGoal(id);
    if (result is Success<bool>) {
      await loadAll();
      return true;
    }
    return false;
  }
}

final trackerControllerProvider =
    StateNotifierProvider<TrackerNotifier, TrackerState>((ref) {
  final repository = ref.watch(trackerRepositoryProvider);
  return TrackerNotifier(repository);
});
