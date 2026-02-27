// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ColorsCustom {
  ColorsCustom._();

  // Primary (Red)
  static const Color primary = Color(0xFF9F2424); // #9F2424
  static const Color primaryDark = Color(0xFF7A1B1B); // #7A1B1B
  static const Color primaryLight = Color(0xFFC14A4A); // #C14A4A
  static const Color primarySoft = Color(0xFFFCF8F8); // #FCF8F8

  // Secondary (Gold)
  static const Color secondary = Color(0xFFD4AF37); // #D4AF37
  static const Color secondaryDark = Color(0xFFB8902E); // #B8902E
  static const Color secondaryLight = Color(0xFFF5E6B3); // #F5E6B3
  static const Color secondarySoft = Color(0xFFFBF3CF); // #FBF3CF

  // Surfaces
  static const Color background = primarySoft; // #FCF8F8
  static const Color surface = Color(0xFFFFFFFF); // #FFFFFF
  static const Color surfaceVariant = Color(0xFFF5F5F5); // #F5F5F5
  static const Color border = Color(0xFFE0E0E0); // #E0E0E0

  // Text
  static const Color textPrimary = Color(0xFF212121); // #212121
  static const Color textSecondary = Color(0xFF757575); // #757575
  static const Color textHint = Color(0xFF9E9E9E); // #9E9E9E
  static const Color textDisabled = Color(0xFFE0E0E0); // #E0E0E0
  static const Color textOnPrimary = Color(0xFFFFFFFF); // #FFFFFF

  // Feedback / Status
  static const Color error = Color(0xFFD32F2F); // #D32F2F
  static const Color errorBg = Color(0xFFFDECEA); // #FDECEA

  static const Color warning = Color(0xFFB8902E); // #B8902E
  static const Color warningBg = Color(0xFFFFF8E1); // #FFF8E1

  static const Color success = Color(0xFF2E7D32); // #2E7D32
  static const Color successBg = Color(0xFFE8F5E9); // #E8F5E9

  // Shadows
  static final shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const overlayGradient = LinearGradient(
    colors: [Color(0xB3000000), Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.0, 0.6],
  );
}
