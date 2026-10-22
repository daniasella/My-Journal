import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_error.dart';
import '../../../shared/models/journal_entry.dart';
import '../../../shared/models/mood_entry.dart';
import '../data/journal_repository.dart';

class JournalState {
  final List<JournalEntry> entries;
  final String searchQuery;
  final MoodType? selectedMood;
  final String? selectedCategory;
  final bool isLoading;
  final String? errorMessage;

  JournalState({
    this.entries = const [],
    this.searchQuery = '',
    this.selectedMood,
    this.selectedCategory,
    this.isLoading = false,
    this.errorMessage,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    String? searchQuery,
    MoodType? selectedMood,
    String? selectedCategory,
    bool? isLoading,
    String? errorMessage,
    bool clearMood = false,
    bool clearCategory = false,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  final JournalRepository _repository;

  JournalNotifier(this._repository) : super(JournalState(isLoading: true)) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getEntries(
      searchQuery: state.searchQuery,
      moodFilter: state.selectedMood,
      categoryFilter: state.selectedCategory,
    );

    if (result is Success<List<JournalEntry>>) {
      state = state.copyWith(entries: result.data, isLoading: false);
    } else if (result is Failure<List<JournalEntry>>) {
      state = state.copyWith(isLoading: false, errorMessage: result.error.message);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadEntries();
  }

  void setMoodFilter(MoodType? mood) {
    if (state.selectedMood == mood) {
      state = state.copyWith(clearMood: true);
    } else {
      state = state.copyWith(selectedMood: mood);
    }
    loadEntries();
  }

  void setCategoryFilter(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
    loadEntries();
  }

  Future<bool> addEntry(JournalEntry entry) async {
    final result = await _repository.createEntry(entry);
    if (result is Success<JournalEntry>) {
      await loadEntries();
      return true;
    }
    return false;
  }

  Future<bool> updateEntry(JournalEntry entry) async {
    final result = await _repository.updateEntry(entry);
    if (result is Success<JournalEntry>) {
      await loadEntries();
      return true;
    }
    return false;
  }

  Future<bool> deleteEntry(String id) async {
    final result = await _repository.deleteEntry(id);
    if (result is Success<bool>) {
      await loadEntries();
      return true;
    }
    return false;
  }
}

final journalControllerProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalNotifier(repository);
});
