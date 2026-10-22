import 'package:flutter/foundation.dart';
import 'mood_entry.dart';

@immutable
class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String entryDate; // YYYY-MM-DD
  final MoodType? mood;
  final String? category;
  final List<String> tags;
  final List<String> photoUrls;
  final String? voiceNoteUrl;
  final double? voiceNoteDurationSeconds;
  final String? voiceNoteObjectKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.entryDate,
    this.mood,
    this.category,
    required this.tags,
    required this.photoUrls,
    this.voiceNoteUrl,
    this.voiceNoteDurationSeconds,
    this.voiceNoteObjectKey,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasVoiceNote =>
      voiceNoteUrl != null || voiceNoteObjectKey != null;
  bool get hasPhotos => photoUrls.isNotEmpty;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      entryDate: json['entry_date'] as String,
      mood: json['mood'] != null
          ? MoodTypeExt.fromString(json['mood'] as String)
          : null,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      voiceNoteUrl: json['voice_note_url'] as String?,
      voiceNoteDurationSeconds:
          (json['voice_note_duration_seconds'] as num?)?.toDouble(),
      voiceNoteObjectKey: json['voice_note_object_key'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'entry_date': entryDate,
      'mood': mood?.label.toLowerCase(),
      'category': category,
      'tags': tags,
      'photo_urls': photoUrls,
      'voice_note_url': voiceNoteUrl,
      'voice_note_duration_seconds': voiceNoteDurationSeconds,
      'voice_note_object_key': voiceNoteObjectKey,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? entryDate,
    MoodType? mood,
    String? category,
    List<String>? tags,
    List<String>? photoUrls,
    String? voiceNoteUrl,
    double? voiceNoteDurationSeconds,
    String? voiceNoteObjectKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      mood: mood ?? this.mood,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      photoUrls: photoUrls ?? this.photoUrls,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      voiceNoteDurationSeconds:
          voiceNoteDurationSeconds ?? this.voiceNoteDurationSeconds,
      voiceNoteObjectKey: voiceNoteObjectKey ?? this.voiceNoteObjectKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
