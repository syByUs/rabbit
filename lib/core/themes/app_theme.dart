import 'package:flutter/material.dart';

/// ============================================
/// Flutter 设计系统 - 基于Figma规范
/// ============================================

class AppColors {
  // 主色调
  static const primary50 = Color(0xFFF0F7FF);
  static const primary100 = Color(0xFFE0F0FF);
  static const primary500 = Color(0xFF1E40AF);
  static const primary600 = Color(0xFF1E3A8A);
  static const primary700 = Color(0xFF1E3A8A);

  // 辅助色
  static const secondary500 = Color(0xFFF472B6);
  static const secondary600 = Color(0xFFEC4899);
  static const accent500 = Color(0xFF60A5FA);
  static const success500 = Color(0xFF10B981);
  static const warning500 = Color(0xFFF59E0B);

  // PRO 主题色
  static const proGold = Color(0xFFF59E0B);
  static const proDarkGold = Color(0xFFD97706);

  // 中性色
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral900 = Color(0xFF111827);

  // 语义化颜色
  static const statusNotStarted = Color(0xFF9CA3AF);
  static const statusLearning = Color(0xFF60A5FA);
  static const statusMastered = Color(0xFF10B981);

  // 文字颜色
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textLink = Color(0xFF1E40AF);
  static const textPro = Color(0xFFF59E0B);

  // 阴影色
  static const shadowLight = Color(0x0D000000);
  static const shadowMedium = Color(0x1A000000);
  static const shadowDark = Color(0x26000000);
}

class AppSpacing {
  // 基础单位 8px
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // 常用边距
  static const EdgeInsetsGeometry containerPadding = EdgeInsets.all(md);
  static const EdgeInsetsGeometry horizontalPadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsetsGeometry verticalPadding = EdgeInsets.symmetric(vertical: md);
}

class AppRadius {
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 20.0;
  static const double full = 9999.0;
}

class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      blurRadius: 2.0,
      offset: Offset(0, 1.0),
      color: AppColors.shadowLight,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      blurRadius: 6.0,
      offset: Offset(0, 4.0),
      color: AppColors.shadowLight,
    ),
    BoxShadow(
      blurRadius: 4.0,
      offset: Offset(0, 2.0),
      color: AppColors.shadowLight,
    ),
  ];

  static const List<BoxShadow> mediumBox = [
    BoxShadow(
      blurRadius: 6.0,
      offset: Offset(0, 4.0),
      color: AppColors.shadowLight,
    ),
    BoxShadow(
      blurRadius: 4.0,
      offset: Offset(0, 2.0),
      color: AppColors.shadowLight,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      blurRadius: 15.0,
      offset: Offset(0, 10.0),
      color: AppColors.shadowMedium,
    ),
    BoxShadow(
      blurRadius: 6.0,
      offset: Offset(0, 4.0),
      color: AppColors.shadowLight,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      blurRadius: 25.0,
      offset: Offset(0, 20.0),
      color: AppColors.shadowMedium,
    ),
    BoxShadow(
      blurRadius: 10.0,
      offset: Offset(0, 10.0),
      color: AppColors.shadowLight,
    ),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(
      blurRadius: 50.0,
      offset: Offset(0, 25.0),
      color: AppColors.shadowDark,
    ),
  ];
}

/// ============================================
/// Flutter 主题配置
/// ============================================

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.neutral50,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.secondary500,
        surface: AppColors.neutral0,
        background: AppColors.neutral50,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral0,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        color: AppColors.neutral0,
        shadowColor: AppColors.shadowLight.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textLink,
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: AppColors.primary500),
        ),
        prefixIconColor: AppColors.textSecondary,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
      ),
      iconTheme: const IconThemeData(
        size: 24.0,
        color: AppColors.textSecondary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        elevation: 4.0,
        sizeConstraints: BoxConstraints.tightFor(width: 56.0, height: 56.0),
        shape: CircleBorder(),
      ),
    );
  }

  /// PRO 按钮样式
  static ButtonStyle get proButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.proGold,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      elevation: 2.0,
      shadowColor: AppColors.proGold.withOpacity(0.3),
    );
  }

  /// 免费版按钮样式
  static ButtonStyle get freeButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary50,
      foregroundColor: AppColors.primary700,
      textStyle: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: AppColors.primary100),
      ),
      elevation: 0,
    );
  }
}

/// ============================================
/// 学习状态样式
/// ============================================

class LearningStatusStyle {
  static Color getBorderColor(String status) {
    switch (status) {
      case 'not-started':
        return AppColors.statusNotStarted;
      case 'learning':
        return AppColors.statusLearning;
      case 'mastered':
        return AppColors.statusMastered;
      default:
        return AppColors.neutral200;
    }
  }

  static Color getBackgroundColor(String status) {
    switch (status) {
      case 'not-started':
        return AppColors.neutral50;
      case 'learning':
        return AppColors.primary50;
      case 'mastered':
        return AppColors.success500.withOpacity(0.1);
      default:
        return AppColors.neutral0;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'not-started':
        return Icons.circle_outlined;
      case 'learning':
        return Icons.circle;
      case 'mastered':
        return Icons.check_circle;
      default:
        return Icons.circle_outlined;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case 'not-started':
        return '未开始';
      case 'learning':
        return '学习中';
      case 'mastered':
        return '已完成';
      default:
        return '未知';
    }
  }
}

/// ============================================
/// 卡片阴影
/// ============================================

class AppDecorations {
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: AppColors.neutral0,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: AppShadows.mediumBox,
      border: Border.all(
        color: AppColors.neutral200.withOpacity(0.5),
        width: 1.0,
      ),
    );
  }

  static BoxDecoration get elevatedCardDecoration {
    return BoxDecoration(
      color: AppColors.neutral0,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: AppShadows.large,
      border: Border.all(
        color: AppColors.neutral100,
        width: 1.0,
      ),
    );
  }

  static BoxDecoration get audioPlayerDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary50, AppColors.neutral0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      boxShadow: AppShadows.large,
    );
  }

  static BoxDecoration get proButtonDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.proGold, AppColors.proDarkGold],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppRadius.full),
      boxShadow: [
        BoxShadow(
          color: AppColors.proGold.withOpacity(0.3),
          blurRadius: 8.0,
          offset: const Offset(0, 4.0),
        ),
      ],
    );
  }
}
