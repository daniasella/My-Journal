import 'package:flutter/foundation.dart';

enum GoalStatus { belumDimulai, sedangBerjalan, selesai }

extension GoalStatusExt on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.belumDimulai: return 'Belum Dimulai';
      case GoalStatus.sedangBerjalan: return 'Sedang Berjalan';
      case GoalStatus.selesai: return 'Selesai';
    }
  }

  static GoalStatus fromString(String value) {
    switch (value) {
      case 'Sedang Berjalan': return GoalStatus.sedangBerjalan;
      case 'Selesai': return GoalStatus.selesai;
      default: return GoalStatus.belumDimulai;
    }
  }
}

@immutable
class GoalMilestone {
  final String id;
  final String goalId;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;

  const GoalMilestone({
    required this.id,
    required this.goalId,
    required this.title,
    required this.isCompleted,
    this.completedAt,
    required this.sortOrder,
  });

  factory GoalMilestone.fromJson(Map<String, dynamic> json) {
    return GoalMilestone(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  GoalMilestone copyWith({
    String? id,
    String? goalId,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
  }) {
    return GoalMilestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestone && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class Goal {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final DateTime? targetDate;
  final double? targetValue;
  final double currentValue;
  final String? unit;
  final String? colorHex;
  final GoalStatus status;
  final List<GoalMilestone> milestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category,
    this.targetDate,
    this.targetValue,
    this.currentValue = 0.0,
    this.unit,
    this.colorHex,
    required this.status,
    required this.milestones,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercent {
    if (milestones.isNotEmpty) {
      final done = milestones.where((m) => m.isCompleted).length;
      return done / milestones.length;
    }
    if (targetValue == null || targetValue == 0) return 0;
    return (currentValue / targetValue!).clamp(0.0, 1.0);
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String?,
      colorHex: json['color_hex'] as String?,
      status: GoalStatusExt.fromString(json['status'] as String? ?? 'Belum Dimulai'),
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => GoalMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'category': category,
      'target_date': targetDate?.toIso8601String(),
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'color_hex': colorHex,
      'status': status.label,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? targetDate,
    double? targetValue,
    double? currentValue,
    String? unit,
    String? colorHex,
    GoalStatus? status,
    List<GoalMilestone>? milestones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      colorHex: colorHex ?? this.colorHex,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
