import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

class AppTheme {
  // Neon Color Palette
  static const Color backgroundColor = Color(0xFF0A0E27);
  static const Color primaryColor = Color(0xFF00F0FF); // Cyan
  static const Color secondaryColor = Color(0xFFFF006E); // Pink
  static const Color accentColor = Color(0xFF8B5CF6); // Purple
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFA0A0A0);
  static const Color borderColor = Color(0xFF334155);
  static const Color cardColor = Color(0x801A2342); // Semi-transparent card background

  // Gradients
  static const LinearGradient neonGradient = LinearGradient(
    colors: [primaryColor, secondaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF0088FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF006E), Color(0xFFFF6B6B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static TextStyle get neonTitle => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        foreground: Paint()..shader = neonGradient.createShader(
          Rect.fromLTWH(0, 0, 200, 100),
        ),
        shadows: [
          Shadow(
            color: primaryColor.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      );

  static TextStyle get neonSubtitle => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        shadows: [
          Shadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      );

  static TextStyle get neonBody => TextStyle(
        fontSize: 16,
        color: textColor,
        height: 1.6,
      );

  static TextStyle get neonSecondary => TextStyle(
        fontSize: 14,
        color: secondaryTextColor,
      );

  static TextStyle get neonButton => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: backgroundColor,
      );

  static TextStyle get neonLabel => TextStyle(
        fontSize: 12,
        color: secondaryTextColor,
        fontWeight: FontWeight.w500,
      );

  // Button Styles
  static ButtonStyle get neonButtonStyle => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(primaryColor),
        foregroundColor: MaterialStateProperty.all(backgroundColor),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.2)),
        shadowColor: MaterialStateProperty.all(primaryColor),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
      );

  static ButtonStyle get secondaryButtonStyle => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(primaryColor),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.1)),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
      );

  // Input Field Styles
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: Color(0x401A2342),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // Card Styles
  static BoxDecoration get neonCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      );

  static BoxDecoration get glowingCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      );

  // Animation Curves and Durations
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOut;

  // Icon Theme
  static IconThemeData get neonIconTheme => IconThemeData(
        color: primaryColor,
        size: 24,
      );

  // App Bar Theme
  static AppBarTheme get appBarTheme => AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleTextStyle: neonTitle.copyWith(fontSize: 20),
        iconTheme: neonIconTheme,
        centerTitle: true,
      );

  // Scaffold Theme
  static ColorScheme get colorScheme => ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        background: backgroundColor,
        error: Colors.red,
        onPrimary: backgroundColor,
        onSecondary: backgroundColor,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
      );

  // Create ThemeData
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: appBarTheme,
        inputDecorationTheme: inputDecorationTheme,
        textTheme: TextTheme(
          displayLarge: neonTitle,
          displayMedium: neonSubtitle,
          bodyLarge: neonBody,
          bodyMedium: neonSecondary,
          labelLarge: neonLabel,
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: neonButtonStyle,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: secondaryButtonStyle,
        ),
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.all(8),
        ),
        dividerColor: borderColor,
        dialogBackgroundColor: cardColor,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: backgroundColor,
          modalBackgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
      );

  // Custom Glow Widget
  static Widget buildGlowingText(
    String text, {
    TextStyle? style,
    Color? glowColor,
    double glowRadius = 20,
    TextAlign? textAlign,
  }) {
    return GlowText(
      text,
      style: style ?? neonTitle,
      glowColor: glowColor ?? primaryColor,
      glowRadius: glowRadius,
      textAlign: textAlign,
    );
  }

  static Widget buildGlowingContainer({
    required Widget child,
    Color? glowColor,
    double glowRadius = 20,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
  }) {
    return GlowContainer(
      color: backgroundColor,
      glowColor: glowColor ?? primaryColor,
      glowRadius: glowRadius,
      padding: padding ?? EdgeInsets.all(16),
      margin: margin ?? EdgeInsets.all(8),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: child,
    );
  }
}