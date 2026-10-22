import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/config/app_constants.dart';
import '../../../shared/models/task.dart';
import '../../auth/domain/auth_controller.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlannerRepository(apiClient);
});

class PlannerRepository {
  final ApiClient _apiClient;
  static const String _storageKey = 'my_journal_cached_tasks';

  PlannerRepository(this._apiClient);

  Future<Result<List<Task>>> getTasks({String? date, String? category}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_storageKey);
      List<Task> tasks = [];

      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        tasks = decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        // Initialize with realistic mock/demo tasks if empty
        tasks = _generateInitialTasks();
        await _saveTasksToLocal(tasks);
      }

      var filtered = tasks;
      if (date != null) {
        filtered = filtered.where((t) => t.dueDate == date).toList();
      }
      if (category != null && category.isNotEmpty) {
        filtered = filtered.where((t) => t.category == category).toList();
      }

      // Sort by priority and time
      filtered.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.priority.index.compareTo(a.priority.index);
      });

      return Success(filtered);
    } catch (e) {
      return Failure(CacheError(e.toString()));
    }
  }

  Future<Result<Task>> createTask(Task task) async {
    try {
      final tasksResult = await getTasks();
      List<Task> tasks = [];
      if (tasksResult is Success<List<Task>>) {
        tasks = List.from(tasksResult.data);
      }

      final newTask = task.copyWith(
        id: task.id.isEmpty ? const Uuid().v4() : task.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      tasks.add(newTask);
      await _saveTasksToLocal(tasks);

      // Best effort API sync
      _syncToApi(newTask);

      return Success(newTask);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<Task>> updateTask(Task task) async {
    try {
      final tasksResult = await getTasks();
      if (tasksResult is! Success<List<Task>>) {
        return Failure(const UnknownError('Gagal memuat tugas'));
      }

      final tasks = List<Task>.from(tasksResult.data);
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) {
        return Failure(const NotFoundError('Tugas tidak ditemukan'));
      }

      final updated = task.copyWith(updatedAt: DateTime.now());
      tasks[index] = updated;
      await _saveTasksToLocal(tasks);

      return Success(updated);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<bool>> deleteTask(String id) async {
    try {
      final tasksResult = await getTasks();
      if (tasksResult is! Success<List<Task>>) {
        return Failure(const UnknownError('Gagal memuat tugas'));
      }

      final tasks = List<Task>.from(tasksResult.data);
      tasks.removeWhere((t) => t.id == id);
      await _saveTasksToLocal(tasks);

      return const Success(true);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<Task>> toggleTaskStatus(String id) async {
    try {
      final tasksResult = await getTasks();
      if (tasksResult is! Success<List<Task>>) {
        return Failure(const UnknownError('Gagal memuat tugas'));
      }

      final tasks = List<Task>.from(tasksResult.data);
      final index = tasks.indexWhere((t) => t.id == id);
      if (index == -1) {
        return Failure(const NotFoundError('Tugas tidak ditemukan'));
      }

      final current = tasks[index];
      final newStatus = current.status == TaskStatus.selesai
          ? TaskStatus.belumSelesai
          : TaskStatus.selesai;
      final updated = current.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      tasks[index] = updated;
      await _saveTasksToLocal(tasks);

      return Success(updated);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<void> _saveTasksToLocal(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void _syncToApi(Task task) async {
    try {
      if (!AppConstants.isDemoMode) {
        await _apiClient.dio.post('/api/tasks', data: task.toJson());
      }
    } catch (_) {
      // Offline fallback: ignore sync errors
    }
  }

  List<Task> _generateInitialTasks() {
    final now = DateTime.now();

    return [
      Task(
        id: 'task-1',
        userId: 'demo-user',
        title: 'Review proposal proyek My Journal',
        description: 'Periksa kembali arsitektur database Neon dan integrasi UI',
        scheduledAt: DateTime(now.year, now.month, now.day, 9, 0),
        priority: TaskPriority.tinggi,
        status: TaskStatus.belumSelesai,
        category: 'Pekerjaan',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: 'task-2',
        userId: 'demo-user',
        title: 'Olahraga pagi 30 menit',
        description: 'Lari santai di taman sekitar rumah',
        scheduledAt: DateTime(now.year, now.month, now.day, 6, 30),
        priority: TaskPriority.sedang,
        status: TaskStatus.selesai,
        category: 'Kesehatan',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      Task(
        id: 'task-3',
        userId: 'demo-user',
        title: 'Membaca 1 bab buku pengembangan diri',
        description: 'Buku Atomic Habits bab 4',
        scheduledAt: DateTime(now.year, now.month, now.day, 20, 0),
        priority: TaskPriority.rendah,
        status: TaskStatus.belumSelesai,
        category: 'Pribadi',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
