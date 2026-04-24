import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════
  //  MENTAL JOURNAL PALETTE
  // ═══════════════════════════════════════════

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF4F6FA);
  static const Color backgroundDark = Color(0xFF0F1117);

  // Bento Card Colors — Light
  static const Color mintCard = Color(0xFFCDF5E4); // Soft mint
  static const Color lavenderCard = Color(0xFFE8E1FF); // Soft lavender
  static const Color blueCard = Color(0xFFD6E8FF); // Soft blue
  static const Color peachCard = Color(0xFFFFE5D9); // Soft peach
  static const Color yellowCard = Color(0xFFFFF3CD); // Soft yellow
  static const Color roseCard = Color(0xFFFFDEE8); // Soft rose

  // Bento Card Colors — Dark
  static const Color mintCardDark = Color(0xFF0D2E22); // Deep mint
  static const Color lavenderCardDark = Color(0xFF1A1530); // Deep lavender
  static const Color blueCardDark = Color(0xFF0D1E35); // Deep blue
  static const Color peachCardDark = Color(0xFF2E1A10); // Deep peach
  static const Color yellowCardDark = Color(0xFF2A2208); // Deep yellow
  static const Color roseCardDark = Color(0xFF2E0F1A); // Deep rose

  // Accent Colors
  static const Color accentGreen = Color(0xFF2ECC8E); // Vivid mint
  static const Color accentPurple = Color(0xFF7C6FF7); // Vivid purple
  static const Color accentBlue = Color(0xFF4A90E2); // Vivid blue
  static const Color accentPeach = Color(0xFFFF7043); // Vivid peach
  static const Color accentGold = Color(0xFFD4A574); // Warm gold

  // Risk Colors (same in both themes)
  static const Color riskLow = Color(0xFF2ECC8E); // Confident green
  static const Color riskMedium = Color(0xFFF5A623); // Warm amber
  static const Color riskHigh = Color(0xFFE85D75); // Soft rose red
  static const Color riskCritical = Color(0xFFD42B50); // Deep rose

  // Text — Light
  static const Color lightTextPrimary = Color(0xFF1A1A2E); // Deep navy
  static const Color lightTextSecond = Color(0xFF6B7394); // Muted
  static const Color lightTextHint = Color(0xFFADB5C8); // Very muted

  // Text — Dark
  static const Color darkTextPrimary = Color(0xFFF0F2FF); // Pearl
  static const Color darkTextSecond = Color(0xFF8890B0); // Muted
  static const Color darkTextHint = Color(0xFF4A5070); // Very muted

  // Surface — Light
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFEEF0F8);

  // Surface — Dark
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkBorder = Color(0xFF2E3350);

  // Legacy aliases
  static const Color primaryColor = accentPurple;
  static const Color accentColor = accentGreen;
  static const Color warningColor = riskMedium;
  static const Color dangerColor = riskHigh;
  static const Color spaceBlack = backgroundDark;
  static const Color spaceDark = Color(0xFF1A1D27);
  static const Color spaceCard = Color(0xFF1E2130);
  static const Color spaceCardLight = Color(0xFF242838);
  static const Color glowColor = accentPurple;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecond;
  static const Color textHint = darkTextHint;
  static const Color backgroundColor = backgroundLight;

  // ═══════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: accentPurple,
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: accentPurple,
      secondary: accentGreen,
      surface: lightSurface,
      background: backgroundLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
    ),

    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(color: lightTextSecond),
      bodyLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary),
      bodyMedium: GoogleFonts.plusJakartaSans(color: lightTextSecond),
      bodySmall: GoogleFonts.plusJakartaSans(color: lightTextHint),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(color: lightTextSecond),
      labelSmall: GoogleFonts.plusJakartaSans(color: lightTextHint),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: lightTextPrimary),
    ),

    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentPurple,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return Colors.white;
        return lightTextHint;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return accentPurple;
        return lightBorder;
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: accentPurple,
      inactiveTrackColor: lightBorder,
      thumbColor: accentPurple,
      overlayColor: accentPurple.withOpacity(0.1),
      valueIndicatorColor: accentPurple,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBorder.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentPurple, width: 2),
      ),
      labelStyle: const TextStyle(color: lightTextSecond),
      hintStyle: const TextStyle(color: lightTextHint),
    ),

    dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),

    listTileTheme: const ListTileThemeData(
      textColor: lightTextPrimary,
      iconColor: accentPurple,
    ),

    iconTheme: const IconThemeData(color: lightTextPrimary),
  );

  // ═══════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: accentPurple,
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: accentPurple,
      secondary: accentGreen,
      surface: Color(0xFF1A1D27),
      background: backgroundDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
    ),

    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(color: darkTextSecond),
      bodyLarge: GoogleFonts.plusJakartaSans(color: darkTextPrimary),
      bodyMedium: GoogleFonts.plusJakartaSans(color: darkTextSecond),
      bodySmall: GoogleFonts.plusJakartaSans(color: darkTextHint),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(color: darkTextSecond),
      labelSmall: GoogleFonts.plusJakartaSans(color: darkTextHint),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E2130),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentPurple,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return Colors.white;
        return darkTextHint;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return accentPurple;
        return darkBorder;
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: accentPurple,
      inactiveTrackColor: darkBorder,
      thumbColor: accentPurple,
      overlayColor: accentPurple.withOpacity(0.2),
      valueIndicatorColor: accentPurple,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF242838),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentPurple, width: 2),
      ),
      labelStyle: const TextStyle(color: darkTextSecond),
      hintStyle: const TextStyle(color: darkTextHint),
    ),

    dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),

    listTileTheme: const ListTileThemeData(
      textColor: darkTextPrimary,
      iconColor: accentPurple,
    ),

    iconTheme: const IconThemeData(color: darkTextPrimary),
  );

  // ═══════════════════════════════════════════
  //  THEME-AWARE HELPERS
  // ═══════════════════════════════════════════

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondOf(BuildContext context) =>
      isDark(context) ? darkTextSecond : lightTextSecond;

  static Color textHintOf(BuildContext context) =>
      isDark(context) ? darkTextHint : lightTextHint;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color primaryOf(BuildContext context) => accentPurple;

  static Color accentOf(BuildContext context) => accentGreen;

  static Color cardColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E2130) : lightSurface;

  static Color cardAltColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF242838) : lightBorder;

  static Color dividerOf(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color goldOf(BuildContext context) => accentGold;

  // Bento card color pair (background, accent)
  static Color bentoCardColor(BuildContext context, BentoColor type) {
    final dark = isDark(context);
    switch (type) {
      case BentoColor.mint:
        return dark ? mintCardDark : mintCard;
      case BentoColor.lavender:
        return dark ? lavenderCardDark : lavenderCard;
      case BentoColor.blue:
        return dark ? blueCardDark : blueCard;
      case BentoColor.peach:
        return dark ? peachCardDark : peachCard;
      case BentoColor.yellow:
        return dark ? yellowCardDark : yellowCard;
      case BentoColor.rose:
        return dark ? roseCardDark : roseCard;
    }
  }

  static Color bentoAccentColor(BentoColor type) {
    switch (type) {
      case BentoColor.mint:
        return accentGreen;
      case BentoColor.lavender:
        return accentPurple;
      case BentoColor.blue:
        return accentBlue;
      case BentoColor.peach:
        return accentPeach;
      case BentoColor.yellow:
        return accentGold;
      case BentoColor.rose:
        return riskHigh;
    }
  }

  // ── Bento Box Decoration ──────────────────────────────────────
  static BoxDecoration bentoDecoration(
    BuildContext context,
    BentoColor type, {
    double borderRadius = 28,
  }) {
    return BoxDecoration(
      color: bentoCardColor(context, type),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // ── Premium Card Decoration ───────────────────────────────────
  static BoxDecoration premiumCard(
    BuildContext context, {
    Color? accentColor,
    double borderRadius = 24,
    bool showAccentBorder = false,
  }) {
    final dark = isDark(context);
    return BoxDecoration(
      color: dark ? const Color(0xFF1E2130) : lightSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: showAccentBorder
            ? (accentColor ?? accentPurple).withOpacity(0.3)
            : (dark ? darkBorder : lightBorder),
        width: showAccentBorder ? 1.5 : 1,
      ),
      boxShadow: dark
          ? []
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  // ── Gradient Card (for Risk Hero) ─────────────────────────────
  static BoxDecoration gradientCard(
    BuildContext context,
    BentoColor type, {
    double borderRadius = 28,
  }) {
    final dark = isDark(context);
    final base = bentoCardColor(context, type);
    final accent = bentoAccentColor(type);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [base, Color.lerp(base, accent, 0.15)!]
            : [base, Color.lerp(base, Colors.white, 0.3)!],
      ),
    );
  }

  // ── Legacy (for existing screens) ─────────────────────────────
  static BoxDecoration glowDecoration({
    Color? color,
    double borderRadius = 16,
    double glowIntensity = 0.3,
  }) {
    return BoxDecoration(
      color: const Color(0xFF1E2130),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (color ?? accentPurple).withOpacity(0.2),
        width: 1,
      ),
    );
  }

  static BoxDecoration starFieldDecoration() {
    return const BoxDecoration(color: backgroundDark);
  }

  static BoxDecoration premiumGradientCard(
    BuildContext context, {
    double borderRadius = 28,
  }) {
    return gradientCard(
      context,
      BentoColor.lavender,
      borderRadius: borderRadius,
    );
  }

  // ═══════════════════════════════════════════
  //  SHARED HELPERS
  // ═══════════════════════════════════════════

  static Color getSeverityColor(int severity) {
    if (severity <= 3) return riskLow;
    if (severity <= 6) return riskMedium;
    return riskHigh;
  }

  static IconData getSeverityIcon(int severity) {
    if (severity <= 3) return Icons.sentiment_satisfied_rounded;
    if (severity <= 6) return Icons.sentiment_neutral_rounded;
    return Icons.sentiment_very_dissatisfied_rounded;
  }

  static Color getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'DÜŞÜK':
        return riskLow;
      case 'ORTA':
        return riskMedium;
      case 'YÜKSEK':
        return riskHigh;
      case 'CRİTİK':
        return riskCritical;
      default:
        return darkTextSecond;
    }
  }

  static BentoColor riskToBento(String riskLevel) {
    switch (riskLevel) {
      case 'DÜŞÜK':
        return BentoColor.mint;
      case 'ORTA':
        return BentoColor.yellow;
      case 'YÜKSEK':
        return BentoColor.rose;
      case 'CRİTİK':
        return BentoColor.rose;
      default:
        return BentoColor.blue;
    }
  }
}

// Bento color types
enum BentoColor { mint, lavender, blue, peach, yellow, rose }
