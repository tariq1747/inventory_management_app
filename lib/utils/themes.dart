import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
  );
}

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.blueAccent;
  static const Color accent = Colors.orange;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
}

class AppConstants {
  static const String appName = 'Inventory Management App';
  static const double defaultTaxRate = 0.18; // 18% GST
  static const int defaultLowStockThreshold = 10;
}
