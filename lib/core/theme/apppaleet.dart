import 'package:flutter/material.dart';

class AppPalette {
  // Primary Colors
  static const Color darkPink = Color(0xFF8B1538);
  static const Color mediumPink = Color(0xFFD81B60);
  static const Color pink = Color(0xFFE91E63);
  static const Color lightPink = Color(0xFFF48FB1);

  // Background Colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color darkGray = Color(0xFF1A1A1A);

  // Text Colors
  static const Color whiteText = Colors.white;
  static final Color grayText = Colors.white.withOpacity(0.5);
  static final Color lightGrayText = Colors.white.withOpacity(0.3);
  static const Color darkGrayText = Colors.white70;

  // Border Colors
  static final Color borderColor = Colors.white.withOpacity(0.2);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    darkPink,
    mediumPink,
    pink,
    lightPink,
  ];

  static const List<Color> sweepGradient = [
    darkPink,
    mediumPink,
    pink,
    lightPink,
    darkPink,
  ];

  // Overlay Colors
  static const Color barrierColor = Colors.black54;
  static const Color transparent = Colors.transparent;
}