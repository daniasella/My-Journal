import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MoodType {
  senang('Senang', '😊', 5, AppColors.moodHappy),
  tenang('Tenang', '😌', 4, AppColors.moodCalm),
  biasa('Biasa', '😐', 3, AppColors.moodNeutral),
  sedih('Sedih', '😢', 2, AppColors.moodSad),
  marah('Marah', '😠', 1, AppColors.moodAngry);

  final String label;
  final String emoji;
  final int value;
  final Color color;

  const MoodType(this.label, this.emoji, this.value, this.color);

  static MoodType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'senang': return MoodType.senang;
      case 'tenang': return MoodType.tenang;
      case 'biasa': return MoodType.biasa;
      case 'sedih': return MoodType.sedih;
      case 'marah': return MoodType.marah;
      default: return MoodType.biasa;
    }
  }

  static MoodType fromValue(int value) {
    switch (value) {
      case 5: return MoodType.senang;
      case 4: return MoodType.tenang;
      case 3: return MoodType.biasa;
      case 2: return MoodType.sedih;
      case 1: return MoodType.marah;
      default: return MoodType.biasa;
    }
  }
}

extension MoodTypeExt on MoodType {
  static MoodType fromString(String value) => MoodType.fromString(value);
  static MoodType fromValue(int value) => MoodType.fromValue(value);
}

@immutable
class MoodEntry {
  final String id;
  final String userId;
  final MoodType mood;
  final String? note;
  final String entryDate; // YYYY-MM-DD
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    this.note,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mood: MoodType.fromString(json['mood'] as String? ?? 'biasa'),
      note: json['note'] as String?,
      entryDate: json['entry_date'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood.label.toLowerCase(),
      'note': note,
      'entry_date': entryDate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    MoodType? mood,
    String? note,
    String? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
