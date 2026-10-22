/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'My Journal';
  static const String appSlogan = 'Plan Your Day. Capture Your Story. Grow Every Day.';
  static const String appSloganId = 'Satu Aplikasi, Banyak Cerita Tentang Kamu.';
  static const String appVersion = '1.0.0';

  // API Base URL — set via environment or config
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://my-journal-api.neon.tech',
  );

  // Demo mode flag
  static const bool isDemoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false,
  );

  // Neon auth endpoint
  static const String authBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: 'https://my-journal-api.neon.tech',
  );

  // Secure storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keySessionToken = 'session_token';

  // Shared prefs keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefLastSyncAt = 'last_sync_at';

  // Mood labels
  static const List<String> moodLabels = [
    'Senang',
    'Tenang',
    'Biasa',
    'Sedih',
    'Marah',
  ];

  // Priority labels
  static const List<String> priorityLabels = ['Tinggi', 'Sedang', 'Rendah'];

  // Category labels
  static const List<String> categoryLabels = [
    'Harian',
    'Pekerjaan',
    'Pendidikan',
    'Pribadi',
    'Kesehatan',
    'Hobi',
    'Kuliah',
    'Lainnya',
  ];

  // Task status labels
  static const String statusBelumSelesai = 'Belum Selesai';
  static const String statusSelesai = 'Selesai';

  // Goal status labels
  static const String goalBelumDimulai = 'Belum Dimulai';
  static const String goalSedangBerjalan = 'Sedang Berjalan';
  static const String goalSelesai = 'Selesai';

  // Habit frequency labels
  static const List<String> habitFrequencyLabels = [
    'Setiap hari',
    '3x seminggu',
    '5x seminggu',
    'Kustom',
  ];

  // Max content length
  static const int maxJournalContent = 5000;
  static const int maxJournalTitle = 100;
  static const int maxTaskTitle = 100;
  static const int maxTaskDescription = 500;
  static const int maxHabitName = 80;
  static const int maxGoalTitle = 100;
  static const int maxBioLength = 150;
  static const int maxDisplayNameLength = 50;
  static const int maxNoteLength = 500;

  // File size limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxAudioSizeBytes = 50 * 1024 * 1024; // 50 MB

  // Pagination
  static const int defaultPageSize = 20;

  // Navigation routes
  static const String routeWelcome = '/welcome';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeHome = '/home';
  static const String routePlanner = '/planner';
  static const String routeJournal = '/journal';
  static const String routeTracker = '/tracker';
  static const String routeInsight = '/insight';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
  static const String routeNotifications = '/notifications';
  static const String routeAddTask = '/add-task';
  static const String routeEditTask = '/edit-task';
  static const String routeTaskDetail = '/task-detail';
  static const String routeAddJournal = '/add-journal';
  static const String routeEditJournal = '/edit-journal';
  static const String routeJournalDetail = '/journal-detail';
  static const String routeVoiceNote = '/voice-note';
  static const String routeAddHabit = '/add-habit';
  static const String routeAddGoal = '/add-goal';
  static const String routeEditProfile = '/edit-profile';
  static const String routePdfExport = '/pdf-export';

  // Error messages
  static const String errorNetwork = 'Terjadi kesalahan koneksi. Periksa internet kamu.';
  static const String errorServer = 'Terjadi kesalahan server. Coba beberapa saat lagi.';
  static const String errorUnauthorized = 'Sesi kamu telah berakhir. Silakan masuk kembali.';
  static const String errorUnknown = 'Terjadi kesalahan yang tidak diketahui.';
  static const String errorNotConfigured = 'Backend belum dikonfigurasi. Mode Demo aktif.';
}
