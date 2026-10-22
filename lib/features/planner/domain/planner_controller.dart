import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/models/task.dart';
import '../data/planner_repository.dart';

class PlannerState {
  final DateTime selectedDate;
  final String? selectedCategory;
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;

  PlannerState({
    required this.selectedDate,
    this.selectedCategory,
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PlannerState copyWith({
    DateTime? selectedDate,
    String? selectedCategory,
    List<Task>? tasks,
    bool? isLoading,
    String? errorMessage,
    bool clearCategory = false,
  }) {
    return PlannerState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<Task> get filteredTasks {
    return tasks.where((t) {
      final matchesDate = t.dueDate == DateFormatter.toIsoDate(selectedDate);
      final matchesCategory = selectedCategory == null || t.category == selectedCategory;
      return matchesDate && matchesCategory;
    }).toList();
  }

  int get completedCount => filteredTasks.where((t) => t.isCompleted).length;
  int get totalCount => filteredTasks.length;
  double get completionProgress => totalCount == 0 ? 0 : completedCount / totalCount;
}

class PlannerNotifier extends StateNotifier<PlannerState> {
  final PlannerRepository _repository;

  PlannerNotifier(this._repository)
      : super(PlannerState(selectedDate: DateTime.now(), isLoading: true)) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getTasks();
    if (result is Success<List<Task>>) {
      state = state.copyWith(tasks: result.data, isLoading: false);
    } else if (result is Failure<List<Task>>) {
      state = state.copyWith(isLoading: false, errorMessage: result.error.message);
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectCategory(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  Future<bool> addTask(Task task) async {
    final result = await _repository.createTask(task);
    if (result is Success<Task>) {
      await loadTasks();
      return true;
    }
    return false;
  }

  Future<bool> updateTask(Task task) async {
    final result = await _repository.updateTask(task);
    if (result is Success<Task>) {
      await loadTasks();
      return true;
    }
    return false;
  }

  Future<bool> deleteTask(String id) async {
    final result = await _repository.deleteTask(id);
    if (result is Success<bool>) {
      await loadTasks();
      return true;
    }
    return false;
  }

  Future<void> toggleTask(String id) async {
    final result = await _repository.toggleTaskStatus(id);
    if (result is Success<Task>) {
      await loadTasks();
    }
  }
}

final plannerControllerProvider =
    StateNotifierProvider<PlannerNotifier, PlannerState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return PlannerNotifier(repository);
});
