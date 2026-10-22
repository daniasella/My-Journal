import 'package:flutter/foundation.dart';

enum HabitFrequency {
  setiapHari('Setiap hari'),
  tigaKaliSeminggu('3x seminggu'),
  limaKaliSeminggu('5x seminggu'),
  kustom('Kustom');

  final String label;
  const HabitFrequency(this.label);

  static HabitFrequency fromString(String value) {
    switch (value) {
      case 'Setiap hari': return HabitFrequency.setiapHari;
      case '3x seminggu': return HabitFrequency.tigaKaliSeminggu;
      case '5x seminggu': return HabitFrequency.limaKaliSeminggu;
      case 'Kustom': return HabitFrequency.kustom;
      default: return HabitFrequency.setiapHari;
    }
  }
}

extension HabitFrequencyExt on HabitFrequency {
  static HabitFrequency fromString(String value) => HabitFrequency.fromString(value);
}

@immutable
class Habit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitFrequency frequency;
  final List<int> activeDays; // 1=Mon ... 7=Sun
  final double? dailyTarget;
  final String? targetUnit;
  final bool reminderEnabled;
  final String? reminderTime; // "HH:mm"
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.frequency,
    required this.activeDays,
    this.dailyTarget,
    this.targetUnit,
    required this.reminderEnabled,
    this.reminderTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      frequency: HabitFrequencyExt.fromString(json['frequency'] as String? ?? 'Setiap hari'),
      activeDays: (json['active_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
      dailyTarget: (json['daily_target'] as num?)?.toDouble(),
      targetUnit: json['target_unit'] as String?,
      reminderEnabled: json['reminder_enabled'] as bool? ?? false,
      reminderTime: json['reminder_time'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'frequency': frequency.label,
      'active_days': activeDays,
      'daily_target': dailyTarget,
      'target_unit': targetUnit,
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitFrequency? frequency,
    List<int>? activeDays,
    double? dailyTarget,
    String? targetUnit,
    bool? reminderEnabled,
    String? reminderTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      activeDays: activeDays ?? this.activeDays,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      targetUnit: targetUnit ?? this.targetUnit,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isScheduledFor(DateTime date) {
    final weekday = date.weekday; // 1=Mon..7=Sun
    return activeDays.contains(weekday);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class HabitLog {
  final String id;
  final String userId;
  final String habitId;
  final String localDate; // YYYY-MM-DD
  final bool isCompleted;
  final double? progress;
  final DateTime updatedAt;

  const HabitLog({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.localDate,
    required this.isCompleted,
    this.progress,
    required this.updatedAt,
  });

  String get logDate => localDate;
  DateTime get loggedAt => updatedAt;

  HabitLog copyWith({
    String? id,
    String? userId,
    String? habitId,
    String? localDate,
    bool? isCompleted,
    double? progress,
    DateTime? updatedAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      localDate: localDate ?? this.localDate,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      localDate: json['local_date'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'local_date': localDate,
      'is_completed': isCompleted,
      'progress': progress,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLog && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
