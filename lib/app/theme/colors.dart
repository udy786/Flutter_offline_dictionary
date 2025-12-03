import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryLight = Color(0xFF4791DB);
  static const Color primaryDark = Color(0xFF115293);

  // Secondary colors
  static const Color secondary = Color(0xFF34A853);
  static const Color secondaryLight = Color(0xFF5DB97E);
  static const Color secondaryDark = Color(0xFF1E7E34);

  // Accent colors
  static const Color accent = Color(0xFFFBBC05);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFF9A825);

  // Text colors
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);

  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // Language badge colors
  static const Color englishBadge = Color(0xFF1A73E8);
  static const Color hindiBadge = Color(0xFFFF9800);

  // Part of speech colors
  static const Color noun = Color(0xFF4CAF50);
  static const Color verb = Color(0xFF2196F3);
  static const Color adjective = Color(0xFFFF9800);
  static const Color adverb = Color(0xFF9C27B0);
  static const Color pronoun = Color(0xFF00BCD4);
  static const Color preposition = Color(0xFF795548);
  static const Color conjunction = Color(0xFF607D8B);
  static const Color interjection = Color(0xFFE91E63);

  // Error and status colors
  static const Color error = Color(0xFFEA4335);
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC05);
  static const Color info = Color(0xFF4285F4);

  static Color getPosColor(String pos) {
    switch (pos.toLowerCase()) {
      case 'noun':
        return noun;
      case 'verb':
        return verb;
      case 'adjective':
      case 'adj':
        return adjective;
      case 'adverb':
      case 'adv':
        return adverb;
      case 'pronoun':
        return pronoun;
      case 'preposition':
        return preposition;
      case 'conjunction':
        return conjunction;
      case 'interjection':
        return interjection;
      default:
        return textSecondary;
    }
  }
}
