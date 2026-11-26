import 'package:flutter/material.dart';

/// 少伟健身通 v3.0 现代运动暗黑 / 清爽分层视觉规范
class AppTheme {
  // 核心品牌能量色
  static const Color neonLime = Color(0xFFC8FF2E); // 活力荧光绿（暗黑高亮/进度/主标签）
  static const Color neonLimeDarkText = Color(0xFF0A0E14);
  static const Color electroOrange = Color(0xFFFF5E1A); // 电光橙（发力向心/核心CTA）
  static const Color emberRed = Color(0xFFF43F5E); // 警示/避坑/B站红粉
  static const Color iceCyan = Color(0xFF38BDF8); // 冰晶蓝（离心控制/蛋白质/呼吸）
  static const Color mintEmerald = Color(0xFF10B981); // 翡翠绿（达标/平替/热量缺口）

  // 深邃运动暗黑层级（无生硬边框，依靠表面色阶和微弱光影分层）
  static const Color darkBg = Color(0xFF090C12);
  static const Color darkSurface = Color(0xFF131822);
  static const Color darkSurfaceElevated = Color(0xFF1B2230);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // 清爽高级浅色层级
  static const Color lightBg = Color(0xFFF3F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEEF2F8);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  /// 卡片柔和层级装饰（彻底去掉生硬边框线）
  static BoxDecoration cardDecoration(
    bool isDark, {
    double radius = 20,
    Color? color,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: color ?? (isDark ? darkSurface : lightSurface),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: glowColor != null
              ? glowColor.withOpacity(isDark ? 0.16 : 0.12)
              : Colors.black.withOpacity(isDark ? 0.28 : 0.05),
          blurRadius: glowColor != null ? 18 : 16,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// 二级嵌套小卡片装饰
  static BoxDecoration innerTileDecoration(bool isDark, {double radius = 14}) {
    return BoxDecoration(
      color: isDark ? darkSurfaceElevated : lightSurfaceElevated,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 品牌高光色（暗黑用荧光绿，浅色用活力橙/深绿以保证可读性）
  static Color accentPrimary(bool isDark) =>
      isDark ? neonLime : electroOrange;

  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: electroOrange,
        secondary: neonLime,
        tertiary: iceCyan,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: neonLimeDarkText,
        onSurface: darkTextPrimary,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          color: darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceElevated,
        contentTextStyle: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: electroOrange,
        secondary: mintEmerald,
        tertiary: Color(0xFF0284C7),
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          color: lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
