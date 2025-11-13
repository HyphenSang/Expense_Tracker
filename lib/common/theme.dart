import 'package:flutter/material.dart';

class AppColors {
  // Core brand colors
  static const Color primary = Color(0xFFD2F273); // Màu chủ đạo: vàng xanh lá nhạt
  static const Color primaryDark = Color(0xFFB8D95A); // Phiên bản đậm hơn
  static const Color primaryLight = Color(0xFFE8F9A0); // Phiên bản nhạt hơn
  static const Color secondary = Color(0xFF6B9F3D); // Xanh lá đậm để bổ sung
  static const Color accent = Color(0xFF4A7C2A); // Màu nhấn đậm
 
  // Neutral colors (grayscale)
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
 
  // Semantic colors
  static const Color success = Color(0xFF10B981); // Xanh lá đậm
  static const Color info = Color(0xFF3B82F6); // Xanh dương
  static const Color warning = Color(0xFFF59E0B); // Cam
  static const Color error = Color(0xFFEF4444); // Đỏ
 
  // Dark mode surfaces
  static const Color darkBg = Color(0xFF0A0E14);
  static const Color darkSurface = Color(0xFF141920);
  static const Color darkSurfaceVariant = Color(0xFF1E252D);
}

/// Spacing và kích thước chuẩn cho app
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 22.0;
  static const double xxl = 26.0;
  
  // Padding chuẩn
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Horizontal padding
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  // Vertical padding
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
}

/// Border radius chuẩn
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  
  // Progress bar radius nhỏ hơn
  static const double progressBar = 3.0;
}

/// Shadow và elevation
class AppShadows {
  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: AppColors.gray200.withValues(alpha: 0.5),
      blurRadius: 10,
      offset: const Offset(0, -2),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.gray200.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

/// Icon sizes chuẩn
class AppIconSizes {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 28.0;
  static const double xl = 30.0;
  static const double xxl = 40.0;
}

/// Gradient colors cho các component
class AppGradients {
  static LinearGradient get reminderBanner => LinearGradient(
    colors: [
      AppColors.primaryLight,
      AppColors.primary.withValues(alpha: 0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
 
/// ThemeData được thiết kế lại với Material 3 và màu chủ đạo #D2F273
class AppTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Inter',
      
      // Typography - Sử dụng font Inter với các weights đã cấu hình
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w700, // Bold (700)
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w700, // Bold (700)
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700, // Bold (700)
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600, // SemiBold (600)
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600, // SemiBold (600)
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600, // SemiBold (600)
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600, // SemiBold (600)
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500, // Medium (500)
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500, // Medium (500)
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.normal, // Regular (400)
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal, // Regular (400)
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.normal, // Regular (400)
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500, // Medium (500)
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500, // Medium (500)
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w500, // Medium (500)
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        centerTitle: true,
        shadowColor: AppColors.gray200,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600, // SemiBold (600)
          color: AppColors.gray900,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: AppColors.gray200,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
          side: BorderSide(color: AppColors.gray200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.gray900,
        unselectedItemColor: AppColors.gray400,
        selectedIconTheme: const IconThemeData(size: AppIconSizes.md),
        unselectedIconTheme: const IconThemeData(size: AppIconSizes.md),
        type: BottomNavigationBarType.fixed,
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray400,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.gray900,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold (600)
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600, // SemiBold (600)
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold (600)
          ),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.gray900,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.primaryLight,
        disabledColor: AppColors.gray200,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray900,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray900,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
 
  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.gray100,
      ),
      scaffoldBackgroundColor: Colors.black,
      canvasColor: AppColors.darkSurface,
      fontFamily: 'Inter',
      
      // Typography - Sử dụng font Inter với các weights đã cấu hình
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w700, // Bold (700)
          letterSpacing: -0.5,
          color: AppColors.gray50,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w700, // Bold (700)
          letterSpacing: -0.5,
          color: AppColors.gray50,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700, // Bold (700)
          color: AppColors.gray50,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600, // SemiBold (600)
          color: AppColors.gray50,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600, // SemiBold (600)
          color: AppColors.gray50,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600, // SemiBold (600)
          color: AppColors.gray50,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600, // SemiBold (600)
          color: AppColors.gray100,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500, // Medium (500)
          color: AppColors.gray100,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500, // Medium (500)
          color: AppColors.gray200,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.normal, // Regular (400)
          color: AppColors.gray200,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal, // Regular (400)
          color: AppColors.gray200,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.normal, // Regular (400)
          color: AppColors.gray300,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500, // Medium (500)
          color: AppColors.gray200,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500, // Medium (500)
          color: AppColors.gray300,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w500, // Medium (500)
          color: AppColors.gray400,
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.gray100,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600, // SemiBold (600)
          color: AppColors.gray100,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gray700.withValues(alpha: 0.5), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray700, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray700, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray500,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.gray900,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold (600)
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600, // SemiBold (600)
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold (600)
          ),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.gray700.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.gray900,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        disabledColor: AppColors.gray700,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray200,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray200,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}