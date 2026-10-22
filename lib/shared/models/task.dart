import 'package:flutter/foundation.dart';

enum TaskPriority { tinggi, sedang, rendah }
enum TaskStatus { belumSelesai, selesai }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.tinggi: return 'Tinggi';
      case TaskPriority.sedang: return 'Sedang';
      case TaskPriority.rendah: return 'Rendah';
    }
  }

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tinggi': return TaskPriority.tinggi;
      case 'sedang': return TaskPriority.sedang;
      case 'rendah': return TaskPriority.rendah;
      default: return TaskPriority.sedang;
    }
  }
}

extension TaskStatusExt on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.belumSelesai: return 'Belum Selesai';
      case TaskStatus.selesai: return 'Selesai';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'selesai': return TaskStatus.selesai;
      default: return TaskStatus.belumSelesai;
    }
  }
}

@immutable
class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final DateTime? deadline;
  final TaskPriority priority;
  final String? category;
  final TaskStatus status;
  final bool reminderEnabled;
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.deadline,
    required this.priority,
    this.category,
    this.status = TaskStatus.belumSelesai,
    this.reminderEnabled = false,
    this.reminderMinutesBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == TaskStatus.selesai;

  String get dueDate =>
      '${scheduledAt.year}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')}';

  String get dueTime =>
      '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      priority: TaskPriorityExt.fromString(json['priority'] as String? ?? 'sedang'),
      category: json['category'] as String?,
      status: TaskStatusExt.fromString(json['status'] as String? ?? 'belum_selesai'),
      reminderEnabled: json['reminder_enabled'] as bool? ?? false,
      reminderMinutesBefore: json['reminder_minutes_before'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'priority': priority.label.toLowerCase(),
      'category': category,
      'status': status == TaskStatus.selesai ? 'selesai' : 'belum_selesai',
      'reminder_enabled': reminderEnabled,
      'reminder_minutes_before': reminderMinutesBefore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    DateTime? deadline,
    TaskPriority? priority,
    String? category,
    TaskStatus? status,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
