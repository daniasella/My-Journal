import 'package:flutter/material.dart';

/// Centralized color palette for My Journal
/// All colors are derived from the official design system specification.
class AppColors {
  AppColors._();

  // ─── Primary Palette ───────────────────────────────────────────────────────
  static const Color primary = Color(0xFF73A88F);       // Hijau Sage Utama
  static const Color primaryDark = Color(0xFF477B64);   // Hijau Tua
  static const Color primaryLight = Color(0xFFE7F1E9);  // Sage Pucat
  static const Color secondary = Color(0xFF477B64);

  // ─── Neutral / Background ──────────────────────────────────────────────────
  static const Color background = Color(0xFFFAF8F3);    // Krem Hangat
  static const Color surface = Color(0xFFFFFFFF);        // Permukaan Putih
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9E7E0);

  // ─── Accent Colors ─────────────────────────────────────────────────────────
  static const Color accentBlue = Color(0xFFE7EFFB);    // Biru Lembut
  static const Color accentPeach = Color(0xFFF8E5DC);   // Persik Pucat
  static const Color accentLavender = Color(0xFFEEE8F7); // Lavender Lembut
  static const Color accentYellow = Color(0xFFFAF0D9);  // Kuning Hangat

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF29352F);
  static const Color textSecondary = Color(0xFF788078);
  static const Color textHint = Color(0xFFC9CDC8);

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFC65D5D);
  static const Color success = Color(0xFF477B64);
  static const Color successLight = Color(0xFFE7F1E9);
  static const Color disabled = Color(0xFFC9CDC8);

  // ─── Priority Colors ───────────────────────────────────────────────────────
  static const Color priorityHigh = Color(0xFFC65D5D);
  static const Color priorityHighBg = Color(0xFFFBEAEA);
  static const Color priorityHighLight = Color(0xFFFBEAEA);
  static const Color priorityMedium = Color(0xFFE8A44A);
  static const Color priorityMediumBg = Color(0xFFFDF3E3);
  static const Color priorityMediumLight = Color(0xFFFDF3E3);
  static const Color priorityLow = Color(0xFF73A88F);
  static const Color priorityLowBg = Color(0xFFE7F1E9);
  static const Color priorityLowLight = Color(0xFFE7F1E9);

  // ─── Mood Colors ───────────────────────────────────────────────────────────
  static const Color moodHappy = Color(0xFFFFD166);
  static const Color moodCalm = Color(0xFF73A88F);
  static const Color moodNeutral = Color(0xFFB0BEC5);
  static const Color moodSad = Color(0xFF90CAF9);
  static const Color moodAngry = Color(0xFFEF9A9A);

  // ─── Category Tag Colors ───────────────────────────────────────────────────
  static const Color tagHarian = Color(0xFF73A88F);
  static const Color tagPekerjaan = Color(0xFF5C7AEA);
  static const Color tagPendidikan = Color(0xFFE8A44A);
  static const Color tagPribadi = Color(0xFFBB86FC);
  static const Color tagKesehatan = Color(0xFFEF9A9A);
  static const Color tagHobi = Color(0xFFFFD166);
  static const Color tagKuliah = Color(0xFF5C7AEA);
  static const Color tagLainnya = Color(0xFFB0BEC5);

  // ─── Shadow ────────────────────────────────────────────────────────────────
  static const Color shadow = Color(0x0F29352F);
  static const Color shadowMedium = Color(0x1A29352F);

  // Dark mode equivalents
  static const Color darkBackground = Color(0xFF1A1F1C);
  static const Color backgroundDark = Color(0xFF1A1F1C);
  static const Color darkSurface = Color(0xFF252B27);
  static const Color surfaceDark = Color(0xFF252B27);
  static const Color cardDark = Color(0xFF252B27);
  static const Color darkBorder = Color(0xFF374039);
  static const Color borderDark = Color(0xFF374039);
  static const Color darkTextPrimary = Color(0xFFE8EDE9);
  static const Color textPrimaryDark = Color(0xFFE8EDE9);
  static const Color darkTextSecondary = Color(0xFF9AAB9C);
  static const Color textSecondaryDark = Color(0xFF9AAB9C);
  static const Color textHintDark = Color(0xFF5C6B5E);
}
