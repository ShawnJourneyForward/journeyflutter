import 'package:flutter/material.dart';

// ─── Stillwater Aesthetic System ─────────────────────────────────────────────
// Light palette mirrors the Tailwind palette in tailwind.config.js exactly.
// Dark palette is a hand-tuned inversion: warm forest-charcoal surfaces with
// the same token names, designed dim (not high-contrast black) because
// recovery hours skew late-night. Light/cream remains the default experience;
// dark is opt-in via Settings → Appearance (system / light / dark).
//
// Every AppColors / AppTextStyles member is a getter that resolves against
// the active palette. The root widget calls AppColors.setDark() before
// building MaterialApp, so the entire token system switches atomically.

class _Palette {
  const _Palette({
    required this.stone50,
    required this.stone100,
    required this.stone200,
    required this.stone300,
    required this.stone400,
    required this.stone500,
    required this.stone600,
    required this.stone700,
    required this.stone800,
    required this.stone900,
    required this.forest50,
    required this.forest100,
    required this.forest200,
    required this.forest300,
    required this.forest400,
    required this.forest500,
    required this.forest600,
    required this.forest700,
    required this.forest800,
    required this.forest900,
    required this.honey50,
    required this.honey100,
    required this.honey200,
    required this.honey300,
    required this.honey400,
    required this.honey500,
    required this.honey600,
    required this.blush50,
    required this.blush100,
    required this.blush400,
    required this.blush500,
    required this.blush600,
    required this.blush700,
    required this.card,
    required this.forestDark,
    required this.stoneText,
    required this.mistGrey,
    required this.leafGreen,
    required this.mintChip,
    required this.softBorder,
    required this.honeySoft,
  });

  final Color stone50,
      stone100,
      stone200,
      stone300,
      stone400,
      stone500,
      stone600,
      stone700,
      stone800,
      stone900;
  final Color forest50,
      forest100,
      forest200,
      forest300,
      forest400,
      forest500,
      forest600,
      forest700,
      forest800,
      forest900;
  final Color honey50, honey100, honey200, honey300, honey400, honey500, honey600;
  final Color blush50, blush100, blush400, blush500, blush600, blush700;
  final Color card,
      forestDark,
      stoneText,
      mistGrey,
      leafGreen,
      mintChip,
      softBorder,
      honeySoft;
}

const _light = _Palette(
  // Cream / Stone — backgrounds, hairlines, secondary text
  stone50: Color(0xFFF5F2EE), // cream — page bg
  stone100: Color(0xFFEDE8E1), // hairlines, chip inputs
  stone200: Color(0xFFD6CFC5),
  stone300: Color(0xFFB8AFA3),
  stone400: Color(0xFF8D99A6), // muted / placeholder
  stone500: Color(0xFF69736F),
  stone600: Color(0xFF55605C), // secondary text
  stone700: Color(0xFF3F4B46),
  stone800: Color(0xFF26332F), // primary ink
  stone900: Color(0xFF18211E),

  // Forest Green — primary CTA, icons, active states
  forest50: Color(0xFFEEF5EE), // icon chip fill
  forest100: Color(0xFFDCE8DC), // card borders, subtle highlights
  forest200: Color(0xFFB9D1B9),
  forest300: Color(0xFF8DBBA0),
  forest400: Color(0xFF6E9E82),
  forest500: Color(0xFF518A6B),
  forest600: Color(0xFF3E745A), // primary CTA
  forest700: Color(0xFF2E5844), // headings, big numerals, active
  forest800: Color(0xFF1E3D2F), // deep dark surface
  forest900: Color(0xFF0F2318),

  // Honey Amber — Daily Gratitude accent only
  honey50: Color(0xFFFAF1DD), // honey chip / soft warning bg
  honey100: Color(0xFFF5E3BB),
  honey200: Color(0xFFEDD39B),
  honey300: Color(0xFFE2BC6E),
  honey400: Color(0xFFD6A84E),
  honey500: Color(0xFFC99846), // Daily Gratitude accent
  honey600: Color(0xFFA8845A), // gratitude icon colour

  // Blush — destructive UI only (delete, slip indicators)
  blush50: Color(0xFFFCF0F0),
  blush100: Color(0xFFF9E1E1),
  blush400: Color(0xFFD97272),
  blush500: Color(0xFFC45E5E),
  blush600: Color(0xFFB54D4D),
  blush700: Color(0xFF943D3D),

  // Luxury surfaces + functional
  card: Color(0xFFFFFDF8), // warm card surface
  forestDark: Color(0xFF1F4D38), // darkest heading ink
  stoneText: Color(0xFF26332F), // body text on cream
  mistGrey: Color(0xFF8D99A6), // labels, placeholders, secondary
  leafGreen: Color(0xFF3F7A5A), // active states, chart line
  mintChip: Color(0xFFE8F1E8), // icon chip fill, quote bg
  softBorder: Color(0x1A2E5844), // 10% forest — card borders
  honeySoft: Color(0xFFF8EBCB), // honey chip background
);

const _dark = _Palette(
  // Stone scale inverts: page bg darkest, primary ink lightest.
  stone50: Color(0xFF161C19), // page bg — warm forest charcoal
  stone100: Color(0xFF202723), // hairlines, chip inputs
  stone200: Color(0xFF2C3530),
  stone300: Color(0xFF3D4843),
  stone400: Color(0xFF707D77), // muted / placeholder
  stone500: Color(0xFF8B9690),
  stone600: Color(0xFFA6B0AA), // secondary text
  stone700: Color(0xFFC4CCC7),
  stone800: Color(0xFFE3E8E4), // primary ink
  stone900: Color(0xFFF1F4F2),

  // Forest: fills darken, accents/inks lighten. forest800/900 stay deep —
  // they are surfaces that carry light text in both modes.
  forest50: Color(0xFF1D2C23), // icon chip fill
  forest100: Color(0xFF27392E), // card borders, subtle highlights
  forest200: Color(0xFF33503F),
  forest300: Color(0xFF4E7560),
  forest400: Color(0xFF6FA083),
  forest500: Color(0xFF82B496),
  forest600: Color(0xFF93C5A8), // primary CTA — dark ink on top
  forest700: Color(0xFFABD3BC), // headings, big numerals, active
  forest800: Color(0xFF24463A), // deep dark surface (still a surface)
  forest900: Color(0xFF16291F),

  // Honey: tinted dark fills, slightly brightened accents.
  honey50: Color(0xFF2E2818),
  honey100: Color(0xFF3B321D),
  honey200: Color(0xFF4D4126),
  honey300: Color(0xFFE2BC6E),
  honey400: Color(0xFFDCAE58),
  honey500: Color(0xFFD8A954),
  honey600: Color(0xFFC9A36B),

  // Blush: tinted dark fills, lifted accents for contrast on dark.
  blush50: Color(0xFF321E1E),
  blush100: Color(0xFF3F2626),
  blush400: Color(0xFFE08888),
  blush500: Color(0xFFD97A7A),
  blush600: Color(0xFFD88282),
  blush700: Color(0xFFE5A1A1),

  card: Color(0xFF1C2320), // lifted card surface
  forestDark: Color(0xFFB5D9C5), // heading ink, inverted to mint
  stoneText: Color(0xFFE3E8E4),
  mistGrey: Color(0xFF79857F),
  leafGreen: Color(0xFF7CB394),
  mintChip: Color(0xFF223129),
  softBorder: Color(0x2EA8D3BB), // 18% mint — card borders
  honeySoft: Color(0xFF332C1B),
);

class AppColors {
  AppColors._();

  static _Palette _p = _light;
  static bool _isDark = false;

  /// Whether the dark palette is active. Set by the root widget before each
  /// build via [setDark]; everything below resolves against the result.
  static bool get isDark => _isDark;

  static void setDark(bool dark) {
    _isDark = dark;
    _p = dark ? _dark : _light;
  }

  // Cream / Stone — backgrounds, hairlines, secondary text
  static Color get stone50 => _p.stone50;
  static Color get stone100 => _p.stone100;
  static Color get stone200 => _p.stone200;
  static Color get stone300 => _p.stone300;
  static Color get stone400 => _p.stone400;
  static Color get stone500 => _p.stone500;
  static Color get stone600 => _p.stone600;
  static Color get stone700 => _p.stone700;
  static Color get stone800 => _p.stone800;
  static Color get stone900 => _p.stone900;

  // Forest Green — primary CTA, icons, active states
  static Color get forest50 => _p.forest50;
  static Color get forest100 => _p.forest100;
  static Color get forest200 => _p.forest200;
  static Color get forest300 => _p.forest300;
  static Color get forest400 => _p.forest400;
  static Color get forest500 => _p.forest500;
  static Color get forest600 => _p.forest600;
  static Color get forest700 => _p.forest700;
  static Color get forest800 => _p.forest800;
  static Color get forest900 => _p.forest900;

  // Honey Amber — Daily Gratitude accent only
  static Color get honey50 => _p.honey50;
  static Color get honey100 => _p.honey100;
  static Color get honey200 => _p.honey200;
  static Color get honey300 => _p.honey300;
  static Color get honey400 => _p.honey400;
  static Color get honey500 => _p.honey500;
  static Color get honey600 => _p.honey600;

  // Blush — destructive UI only (delete, slip indicators)
  static Color get blush50 => _p.blush50;
  static Color get blush100 => _p.blush100;
  static Color get blush400 => _p.blush400;
  static Color get blush500 => _p.blush500;
  static Color get blush600 => _p.blush600;
  static Color get blush700 => _p.blush700;

  // ─── Luxury Aesthetic System ──────────────────────────────────────────────
  static Color get card => _p.card;

  // Typography hierarchy
  static Color get forestDark => _p.forestDark;
  static Color get stoneText => _p.stoneText;
  static Color get mistGrey => _p.mistGrey;

  // UI functional
  static Color get leafGreen => _p.leafGreen;
  static Color get mintChip => _p.mintChip;
  static Color get softBorder => _p.softBorder;
  static Color get honeySoft => _p.honeySoft;

  // Semantic aliases
  static Color get cream => stone50;
  static Color get forest => forest700;
  static Color get honey => honey500;
  static Color get background => cream;
  static Color get surfaceCard => card;
  static Color get primaryText => stoneText;
  static Color get secondaryText => stone600;
  static Color get placeholder => stone400;
  static Color get primary => forest;
  static Color get primaryDark => forestDark;
  static Color get accent => honey;
  static Color get danger => blush600;

  /// Ink for content sitting on a `forest600`-filled control (CTA buttons).
  /// White in light mode; deep charcoal in dark mode where forest600 is a
  /// light mint fill.
  static Color get onForest => _isDark ? _p.stone50 : Colors.white;
}

// ─── Typography ───────────────────────────────────────────────────────────────
// Fraunces = display / serif headings  |  Inter = body / UI
// Both fonts are bundled as variable .ttf files in assets/fonts/. Flutter
// resolves any weight (100–900) from the single file — no Google Fonts CDN
// round-trip required. This makes the app fully offline and removes the
// "100% on device" caveat that google_fonts.gstatic.com previously created.

const _kSerif = 'Fraunces';
const _kSans = 'Inter';

class AppTextStyles {
  AppTextStyles._();

  // Serif display — sober counter, big numerals, milestone labels
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w500,
        fontSize: 56,
        height: 1.05,
        color: AppColors.forestDark,
        letterSpacing: -0.7,
      );
  static TextStyle get displayMedium => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w500,
        fontSize: 40,
        height: 1.1,
        color: AppColors.forestDark,
      );
  static TextStyle get displaySmall => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w500,
        fontSize: 32,
        height: 1.15,
        color: AppColors.forestDark,
      );
  static TextStyle get greetingSerif => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w500,
        fontSize: 30,
        height: 1.12,
        color: AppColors.forestDark,
        letterSpacing: -0.2,
      );
  static TextStyle get heroNumber => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w300,
        fontSize: 80,
        height: 1.0,
        color: AppColors.forestDark,
        letterSpacing: -1.0,
      );
  static TextStyle get moneyNumber => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w300,
        fontSize: 40,
        height: 1.0,
        color: AppColors.forestDark,
        letterSpacing: -0.5,
      );

  // Serif body — affirmation cards, journal prompts, recovery prose
  static TextStyle get headlineSerif => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w400,
        fontSize: 22,
        height: 1.35,
        color: AppColors.stoneText,
      );
  static TextStyle get bodySerif => TextStyle(
        fontFamily: _kSerif,
        fontWeight: FontWeight.w400,
        fontSize: 17,
        height: 1.5,
        color: AppColors.stoneText,
      );

  // Sans — all UI labels, buttons, nav
  static TextStyle get titleLarge => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        height: 1.3,
        color: AppColors.stoneText,
      );
  static TextStyle get titleMedium => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.35,
        color: AppColors.stoneText,
      );
  static TextStyle get titleSmall => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        height: 1.4,
        color: AppColors.stoneText,
      );
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w400,
        fontSize: 17,
        height: 1.45,
        color: AppColors.stoneText,
      );
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.5,
        color: AppColors.stoneText,
      );
  static TextStyle get bodySmall => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
        color: AppColors.mistGrey,
      );
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.3,
        letterSpacing: 0.1,
      );
  static TextStyle get labelMedium => const TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.25,
        letterSpacing: 0.2,
      );
  static TextStyle get labelSmall => const TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w600,
        fontSize: 10,
        height: 1.2,
        letterSpacing: 0.8,
      );
  static TextStyle get caption => TextStyle(
        fontFamily: _kSans,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        height: 1.3,
        color: AppColors.mistGrey,
        letterSpacing: 0.3,
      );
  static TextStyle get overline => TextStyle(
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
  // each card's first paint during a flick rasterizes the soft penumbra).
  //
  // Two cuts so far: 45 → 18 → 10. Round-tripping the math:
  //   (45/10)² ≈ 20× cheaper than the original luxury blur, and
  //   (18/10)² ≈ 3.2× cheaper than the post-launch pass.
  // spreadRadius lifted from -4 → -2 so the visible halo footprint stays
  // close to what it was at blurRadius 18 (smaller blur + the old spread
  // would have read as a tight pill instead of a soft lift). Contact
  // shadow blurRadius 6 → 4 for the same reason on the close-up tier.
  static const luxury = [
    BoxShadow(
      color: Color(0x1A1F4D38), // 10% forestDark — depth holds at this
                                 // alpha because the smaller blur keeps
                                 // more of the colour in the visible halo.
      blurRadius: 10,
      offset: Offset(0, 10),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x0A1F4D38), // 4% forestDark — close contact shadow
      blurRadius: 4,
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

ThemeData buildAppTheme({bool highContrast = false, bool dark = false}) {
  // High-contrast variant — darkens forest tones to reach WCAG AAA on text,
  // lifts borders from 10% to 40% forest, and replaces placeholder mist-grey
  // with stone700. The dark variant resolves through the same tokens (the
  // caller switches AppColors first), so high-contrast composes with it.
  final onForest = AppColors.onForest;
  final colorScheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: highContrast && !dark ? AppColors.forest800 : AppColors.forest600,
    onPrimary: onForest,
    primaryContainer: AppColors.forest100,
    onPrimaryContainer: dark ? AppColors.forest700 : AppColors.forest900,
    secondary: highContrast ? AppColors.honey600 : AppColors.honey500,
    onSecondary: dark ? AppColors.stone50 : Colors.white,
    secondaryContainer: AppColors.honey50,
    onSecondaryContainer: dark ? AppColors.stone800 : AppColors.forest800,
    error: highContrast ? AppColors.blush700 : AppColors.blush600,
    onError: dark ? AppColors.stone50 : Colors.white,
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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: dark ? AppColors.card : Colors.white,
      selectedItemColor: AppColors.forest600,
      unselectedItemColor: AppColors.stone400,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      unselectedLabelStyle: const TextStyle(
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
        foregroundColor: onForest,
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
        side: BorderSide(color: AppColors.forest200, width: 1.5),
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
        borderSide: BorderSide(color: AppColors.stone100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: BorderSide(color: AppColors.stone100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: BorderSide(color: AppColors.forest600, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.lg,
        borderSide: BorderSide(color: AppColors.blush600),
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
      side: BorderSide(color: AppColors.stone100),
      labelStyle: AppTextStyles.bodySmall,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.stone100,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.forest600,
      linearTrackColor: AppColors.stone100,
      linearMinHeight: 6,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.forest600,
      inactiveTrackColor: AppColors.stone100,
      thumbColor: AppColors.forest600,
      overlayColor: const Color(0x1A3E745A),
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
    textTheme: TextTheme(
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
