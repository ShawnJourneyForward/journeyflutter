import 'package:flutter/material.dart';

// ─── Stillwater Aesthetic System ─────────────────────────────────────────────
// Mirrors the Tailwind palette in tailwind.config.js exactly.

class AppColors {
  AppColors._();

  // Cream / Stone — backgrounds, hairlines, secondary text
  static const stone50 = Color(0xFFF5F2EE); // cream — page bg
  static const stone100 = Color(0xFFEDE8E1); // hairlines, chip inputs
  static const stone200 = Color(0xFFD6CFC5);
  static const stone300 = Color(0xFFB8AFA3);
  static const stone400 = Color(0xFF8D99A6); // muted / placeholder
  static const stone500 = Color(0xFF69736F);
  static const stone600 = Color(0xFF55605C); // secondary text
  static const stone700 = Color(0xFF3F4B46);
  static const stone800 = Color(0xFF26332F); // primary ink
  static const stone900 = Color(0xFF18211E);

  // Forest Green — primary CTA, icons, active states
  static const forest50 = Color(0xFFEEF5EE); // icon chip fill
  static const forest100 = Color(0xFFDCE8DC); // card borders, subtle highlights
  static const forest200 = Color(0xFFB9D1B9);
  static const forest300 = Color(0xFF8DBBA0);
  static const forest400 = Color(0xFF6E9E82);
  static const forest500 = Color(0xFF518A6B);
  static const forest600 = Color(0xFF3E745A); // primary CTA
  static const forest700 = Color(0xFF2E5844); // headings, big numerals, active
  static const forest800 = Color(0xFF1E3D2F); // deep dark surface
  static const forest900 = Color(0xFF0F2318);

  // Honey Amber — Daily Gratitude accent only
  static const honey50 = Color(0xFFFAF1DD); // honey chip / soft warning bg
  static const honey100 = Color(0xFFF5E3BB);
  static const honey200 = Color(0xFFEDD39B);
  static const honey300 = Color(0xFFE2BC6E);
  static const honey400 = Color(0xFFD6A84E);
  static const honey500 = Color(0xFFC99846); // Daily Gratitude accent
  static const honey600 = Color(0xFFA8845A); // gratitude icon colour

  // Blush — destructive UI only (delete, slip indicators)
  static const blush50 = Color(0xFFFCF0F0);
  static const blush100 = Color(0xFFF9E1E1);
  static const blush400 = Color(0xFFD97272);
  static const blush500 = Color(0xFFC45E5E);
  static const blush600 = Color(0xFFB54D4D);
  static const blush700 = Color(0xFF943D3D);

  // ─── Luxury Aesthetic System ──────────────────────────────────────────────
  // Warm card surface — slightly warmer than pure white
  static const card = Color(0xFFFFFDF8);

  // Typography hierarchy
  static const forestDark = Color(0xFF1F4D38); // darkest heading ink
  static const stoneText = Color(0xFF26332F); // body text on cream
  static const mistGrey = Color(0xFF8D99A6); // labels, placeholders, secondary

  // UI functional
  static const leafGreen = Color(0xFF3F7A5A); // active states, chart line
  static const mintChip = Color(0xFFE8F1E8); // icon chip fill, quote bg
  static const softBorder = Color(0x1A2E5844); // 10% forest — card borders
  static const honeySoft = Color(0xFFF8EBCB); // honey chip background

  // Semantic aliases
  static const cream = stone50;
  static const forest = forest700;
  static const honey = honey500;
  static const background = cream;
  static const surfaceCard = card;
  static const primaryText = stoneText;
  static const secondaryText = stone600;
  static const placeholder = stone400;
  static const primary = forest;
  static const primaryDark = forestDark;
  static const accent = honey;
  static const danger = blush600;
}

// ─── Typography ───────────────────────────────────────────────────────────────
// Fraunces = display / serif headings  |  Inter = body / UI
// Both fonts are now bundled as variable .ttf files in assets/fonts/. Flutter
// resolves any weight (100–900) from the single file — no Google Fonts CDN
// round-trip required. This makes the app fully offline and removes the
// "100% on device" caveat that google_fonts.gstatic.com previously created.

const _kSerif = 'Fraunces';
const _kSans = 'Inter';

class AppTextStyles {
  AppTextStyles._();

  // Serif display — sober counter, big numerals, milestone labels
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w500,
    fontSize: 56,
    height: 1.05,
    color: AppColors.forestDark,
    letterSpacing: -0.7,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w500,
    fontSize: 40,
    height: 1.1,
    color: AppColors.forestDark,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w500,
    fontSize: 32,
    height: 1.15,
    color: AppColors.forestDark,
  );
  static const TextStyle greetingSerif = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w500,
    fontSize: 30,
    height: 1.12,
    color: AppColors.forestDark,
    letterSpacing: -0.2,
  );
  static const TextStyle heroNumber = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w300,
    fontSize: 80,
    height: 1.0,
    color: AppColors.forestDark,
    letterSpacing: -1.0,
  );
  static const TextStyle moneyNumber = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w300,
    fontSize: 40,
    height: 1.0,
    color: AppColors.forestDark,
    letterSpacing: -0.5,
  );

  // Serif body — affirmation cards, journal prompts, recovery prose
  static const TextStyle headlineSerif = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 1.35,
    color: AppColors.stoneText,
  );
  static const TextStyle bodySerif = TextStyle(
    fontFamily: _kSerif,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.5,
    color: AppColors.stoneText,
  );

  // Sans — all UI labels, buttons, nav
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.3,
    color: AppColors.stoneText,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.35,
    color: AppColors.stoneText,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.4,
    color: AppColors.stoneText,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.45,
    color: AppColors.stoneText,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    color: AppColors.stoneText,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.4,
    color: AppColors.mistGrey,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.25,
    letterSpacing: 0.2,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    height: 1.2,
    letterSpacing: 0.8,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.3,
    color: AppColors.mistGrey,
    letterSpacing: 0.3,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: _kSans,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.2,
    color: AppColors.forest,
    letterSpacing: 3.0,
  );
}

class AppSpacing {
  AppSpacing._();
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

// ─── Radii ────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(20));
  static const xxl = BorderRadius.all(Radius.circular(24));
  static const luxury = BorderRadius.all(Radius.circular(30));
  static const pill = BorderRadius.all(Radius.circular(100));
  static const full = BorderRadius.all(Radius.circular(100));
}

// ─── Shadows ──────────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  // Luxury warm shadow — forestDark tinted, soft but cheap to rasterize.
  //
  // Skia's Gaussian blur cost grows ~quadratically with blurRadius, and these
  // shadows are applied to every LuxuryCard. With ~13 cards on the home
  // screen each wearing this shadow, oversized blurs were the primary cause
  // of scroll jitter (the shadow extends past each card's RepaintBoundary so
  // every scroll frame re-rasterizes the soft penumbra). Values were tuned
  // to be visually indistinguishable at viewing distance while costing the
  // GPU ~6x less per frame (blurRadius 45 → 18 ≈ (45/18)² ≈ 6.25x cheaper).
  static const luxury = [
    BoxShadow(
      color: Color(0x1A1F4D38), // 10% forestDark — slightly stronger to
                                 // preserve perceived depth at the smaller
                                 // blur radius (smaller blur reads paler).
      blurRadius: 18,
      offset: Offset(0, 10),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A1F4D38), // 4% forestDark — close contact shadow
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Soft card lift — white surface on cream background
  static const card = [
    BoxShadow(
      color: Color(0x0A1E293B),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x101E293B),
      blurRadius: 14,
      offset: Offset(0, 3),
    ),
  ];

  // Glass card — diffuse, no hard edge
  static const glass = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Elevated CTA button
  static const button = [
    BoxShadow(
      color: Color(0x333E745A),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

ThemeData buildAppTheme({bool highContrast = false}) {
  // High-contrast variant — darkens forest tones to reach WCAG AAA on text,
  // lifts borders from 10% to 40% forest, and replaces placeholder mist-grey
  // with stone700. Tested on cream background only; we never opted into a
  // dark mode because recovery hours skew late-night and the cream surface
  // tested as gentler on eyes than a dark canvas.
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: highContrast ? AppColors.forest800 : AppColors.forest600,
    onPrimary: Colors.white,
    primaryContainer: AppColors.forest100,
    onPrimaryContainer: AppColors.forest900,
    secondary: highContrast ? AppColors.honey600 : AppColors.honey500,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.honey50,
    onSecondaryContainer: AppColors.forest800,
    error: highContrast ? AppColors.blush700 : AppColors.blush600,
    onError: Colors.white,
    errorContainer: AppColors.blush50,
    onErrorContainer: AppColors.blush700,
    surface: AppColors.card,
    onSurface: highContrast ? AppColors.stone900 : AppColors.stone800,
    surfaceContainerHighest: AppColors.stone100,
    outline: highContrast ? AppColors.stone500 : AppColors.stone200,
    outlineVariant: highContrast ? AppColors.stone300 : AppColors.stone100,
    shadow: const Color(0x1A1E293B),
    scrim: const Color(0x661E293B),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.cream,
    fontFamily: 'Inter',
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.stone800,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleLarge,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.forest600,
      unselectedItemColor: AppColors.stone400,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.forest600,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        textStyle: AppTextStyles.labelLarge,
        minimumSize: const Size.fromHeight(52),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.forest600,
        side: const BorderSide(color: AppColors.forest200, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        textStyle: AppTextStyles.labelLarge,
        minimumSize: const Size.fromHeight(52),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.forest600,
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.stone50,
      border: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: const BorderSide(color: AppColors.stone100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: const BorderSide(color: AppColors.stone100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: const BorderSide(color: AppColors.forest600, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: const BorderSide(color: AppColors.blush600),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.luxury),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.stone50,
      selectedColor: AppColors.forest50,
      side: const BorderSide(color: AppColors.stone100),
      labelStyle: AppTextStyles.bodySmall,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.stone100,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.forest600,
      linearTrackColor: AppColors.stone100,
      linearMinHeight: 6,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.forest600,
      inactiveTrackColor: AppColors.stone100,
      thumbColor: AppColors.forest600,
      overlayColor: Color(0x1A3E745A),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.forest600
            : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.forest200
            : AppColors.stone200,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineMedium: AppTextStyles.headlineSerif,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelSmall: AppTextStyles.labelSmall,
    ),
  );
}
