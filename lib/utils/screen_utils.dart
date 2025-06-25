import 'package:flutter/material.dart';

/// Utility class untuk mengatur responsivitas UI dan mencegah overflow
class ScreenUtils {
  // Spesifik untuk Poco X3 Pro (1080 x 2400 pixels)
  static double screenWidth = 1080;
  static double screenHeight = 2400;
  static double blockSizeHorizontal = 1080 / 100; // Tetap 10.8
  static double blockSizeVertical = 2400 / 100; // Tetap 24.0

  // Batasan ukuran untuk mencegah overflow
  static const double maxFontSize = 24.0;
  static const double maxIconSize = 48.0;

  /// Mengembalikan ukuran relatif terhadap lebar layar dengan batasan
  static double w(double width) {
    return width; // Gunakan ukuran tetap untuk mencegah masalah layout
  }

  /// Mengembalikan ukuran relatif terhadap tinggi layar dengan batasan
  static double h(double height) {
    return height; // Gunakan ukuran tetap untuk mencegah masalah layout
  }

  /// Skala font sesuai ukuran layar dengan batasan maksimum
  static double sp(double size) {
    return size.clamp(0.0, maxFontSize); // Terapkan batasan untuk font
  }

  /// Ukuran ikon dengan batasan maksimum
  static double iconSize(double size) {
    return size.clamp(0.0, maxIconSize); // Terapkan batasan untuk ikon
  }

  /// Menentukan apakah layar berukuran kecil (mobile)
  static bool isMobileScreen() {
    return true; // Selalu true karena ini app mobile
  }

  /// Mendapatkan faktor skala yang sesuai
  static double getScaleFactor() {
    return 1.0; // Gunakan skala 1.0 untuk konsistensi
  }

  /// Membuat ukuran padding yang responsif dan aman
  static EdgeInsets responsivePadding(
      {double horizontal = 0.0,
      double vertical = 0.0,
      double all = 0.0,
      double left = 0.0,
      double right = 0.0,
      double top = 0.0,
      double bottom = 0.0}) {
    if (all > 0) {
      return EdgeInsets.all(all);
    }

    return EdgeInsets.fromLTRB(
        left > 0
            ? left
            : horizontal > 0
                ? horizontal
                : 0.0,
        top > 0
            ? top
            : vertical > 0
                ? vertical
                : 0.0,
        right > 0
            ? right
            : horizontal > 0
                ? horizontal
                : 0.0,
        bottom > 0
            ? bottom
            : vertical > 0
                ? vertical
                : 0.0);
  }

  /// Mendapatkan font size yang aman berdasarkan ukuran layar
  static double getAdaptiveFontSize(double size) {
    return size.clamp(8.0, maxFontSize);
  }

  static void init(BuildContext context) {}
}

/// Extension untuk memudahkan penggunaan
extension SizeExtension on num {
  double get w => toDouble(); // Ubah ke nilai tetap
  double get h => toDouble(); // Ubah ke nilai tetap
  double get sp => toDouble(); // Ubah ke nilai tetap
  double get iconSize => ScreenUtils.iconSize(toDouble());
  double get adaptiveFont => ScreenUtils.getAdaptiveFontSize(toDouble());
}
