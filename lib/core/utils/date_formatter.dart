import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  DateFormatter._();

  static bool _initialized = false;

  static void ensureInitialized() {
    if (!_initialized) {
      try {
        initializeDateFormatting('id_ID', null);
      } catch (_) {}
      _initialized = true;
    }
  }

  static DateFormat get _dayFormat {
    ensureInitialized();
    return DateFormat('EEEE', 'id_ID');
  }

  static DateFormat get _dateFormat {
    ensureInitialized();
    return DateFormat('dd MMMM yyyy', 'id_ID');
  }

  static DateFormat get _shortDateFormat {
    ensureInitialized();
    return DateFormat('dd MMM yyyy', 'id_ID');
  }

  static DateFormat get _timeFormat {
    ensureInitialized();
    return DateFormat('HH:mm', 'id_ID');
  }

  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String toIsoDate(DateTime dt) => _isoFormat.format(dt);

  static DateTime parseIsoDate(String str) => _isoFormat.parse(str);

  static String formatFull(DateTime dt) {
    return '${_dayFormat.format(dt)}, ${_dateFormat.format(dt)}';
  }

  static String formatShort(DateTime dt) => _shortDateFormat.format(dt);

  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final difference = today.difference(date).inDays;

    if (difference == 0) {
      return 'Hari ini, ${formatTime(dt)}';
    } else if (difference == 1) {
      return 'Kemarin, ${formatTime(dt)}';
    } else if (difference == -1) {
      return 'Besok, ${formatTime(dt)}';
    } else if (difference > 1 && difference < 7) {
      return '$difference hari yang lalu';
    } else {
      return _shortDateFormat.format(dt);
    }
  }

  static String formatGreeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
