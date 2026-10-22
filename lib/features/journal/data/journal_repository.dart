import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/config/app_constants.dart';
import '../../../shared/models/journal_entry.dart';
import '../../../shared/models/mood_entry.dart';
import '../../auth/domain/auth_controller.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JournalRepository(apiClient);
});

class JournalRepository {
  final ApiClient _apiClient;
  static const String _storageKey = 'my_journal_cached_entries';

  JournalRepository(this._apiClient);

  Future<Result<List<JournalEntry>>> getEntries({
    String? searchQuery,
    MoodType? moodFilter,
    String? categoryFilter,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_storageKey);
      List<JournalEntry> entries = [];

      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        entries = decoded.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        entries = _generateInitialEntries();
        await _saveEntriesToLocal(entries);
      }

      var filtered = entries;

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        filtered = filtered.where((e) {
          final titleMatch = e.title.toLowerCase().contains(q);
          final contentMatch = e.content.toLowerCase().contains(q);
          final tagMatch = e.tags.any((t) => t.toLowerCase().contains(q));
          return titleMatch || contentMatch || tagMatch;
        }).toList();
      }

      if (moodFilter != null) {
        filtered = filtered.where((e) => e.mood == moodFilter).toList();
      }

      if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'Semua') {
        filtered = filtered.where((e) => e.category == categoryFilter).toList();
      }

      // Sort newest first
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Success(filtered);
    } catch (e) {
      return Failure(CacheError(e.toString()));
    }
  }

  Future<Result<JournalEntry>> getEntryById(String id) async {
    try {
      final entriesResult = await getEntries();
      if (entriesResult is Success<List<JournalEntry>>) {
        final entry = entriesResult.data.firstWhere(
          (e) => e.id == id,
          orElse: () => throw Exception('Entry not found'),
        );
        return Success(entry);
      }
      return Failure(const NotFoundError('Catatan jurnal tidak ditemukan'));
    } catch (e) {
      return Failure(NotFoundError(e.toString()));
    }
  }

  Future<Result<JournalEntry>> createEntry(JournalEntry entry) async {
    try {
      final entriesResult = await getEntries();
      List<JournalEntry> entries = [];
      if (entriesResult is Success<List<JournalEntry>>) {
        entries = List.from(entriesResult.data);
      }

      final newEntry = entry.copyWith(
        id: entry.id.isEmpty ? const Uuid().v4() : entry.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      entries.insert(0, newEntry);
      await _saveEntriesToLocal(entries);

      _syncToApi(newEntry);

      return Success(newEntry);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<JournalEntry>> updateEntry(JournalEntry entry) async {
    try {
      final entriesResult = await getEntries();
      if (entriesResult is! Success<List<JournalEntry>>) {
        return Failure(const UnknownError('Gagal memuat catatan jurnal'));
      }

      final entries = List<JournalEntry>.from(entriesResult.data);
      final index = entries.indexWhere((e) => e.id == entry.id);
      if (index == -1) {
        return Failure(const NotFoundError('Catatan jurnal tidak ditemukan'));
      }

      final updated = entry.copyWith(updatedAt: DateTime.now());
      entries[index] = updated;
      await _saveEntriesToLocal(entries);

      return Success(updated);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<bool>> deleteEntry(String id) async {
    try {
      final entriesResult = await getEntries();
      if (entriesResult is! Success<List<JournalEntry>>) {
        return Failure(const UnknownError('Gagal memuat catatan jurnal'));
      }

      final entries = List<JournalEntry>.from(entriesResult.data);
      entries.removeWhere((e) => e.id == id);
      await _saveEntriesToLocal(entries);

      return const Success(true);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<void> _saveEntriesToLocal(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void _syncToApi(JournalEntry entry) async {
    try {
      if (!AppConstants.isDemoMode) {
        await _apiClient.dio.post('/api/journals', data: entry.toJson());
      }
    } catch (_) {}
  }

  List<JournalEntry> _generateInitialEntries() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    return [
      JournalEntry(
        id: 'journal-1',
        userId: 'demo-user',
        title: 'Langkah Awal Menuju Konsistensi',
        content: 'Hari ini saya memulai kebiasaan baru untuk menulis jurnal dan merencanakan hari lebih rapi. Rasanya pikiran menjadi jauh lebih tenang dan terorganisir. Bersyukur untuk hari yang produktif ini!',
        entryDate: todayStr,
        mood: MoodType.senang,
        category: 'Pribadi',
        tags: ['Refleksi', 'Produktif', 'Syukur'],
        photoUrls: [],
        voiceNoteUrl: null,
        voiceNoteDurationSeconds: null,
        voiceNoteObjectKey: null,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      JournalEntry(
        id: 'journal-2',
        userId: 'demo-user',
        title: 'Menenangkan Diri di Sore Hari',
        content: 'Sore ini menikmati secangkir teh hangat sembari mendengarkan musik santai. Terkadang berhenti sejenak dari hiruk pikuk pekerjaan memberikan energi baru untuk melangkah esok hari.',
        entryDate: yesterdayStr,
        mood: MoodType.tenang,
        category: 'Kesehatan',
        tags: ['Ketenangan', 'Santai'],
        photoUrls: [],
        voiceNoteUrl: null,
        voiceNoteDurationSeconds: null,
        voiceNoteObjectKey: null,
        createdAt: yesterday.subtract(const Duration(hours: 4)),
        updatedAt: yesterday.subtract(const Duration(hours: 4)),
      ),
    ];
  }
}
