import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/prodi_detail_screen.dart';
import 'screens/prodi_search_screen.dart';
import 'screens/pt_detail_screen.dart';
import 'screens/dosen_search_screen_new.dart';
import 'screens/dosen_detail_screen.dart';
import 'api/api_factory.dart';
import 'utils/constants.dart';

void main() {
  // Enable Flutter Web error logging in console
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error: ${details.exception}');
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Poco X3 Pro specific dimensions
    const double screenWidth = 1080;
    const double screenHeight = 2400;

    return Provider<ApiFactory>(
      create: (_) => ApiFactory(),
      child: MaterialApp(
        title: 'DB Cracker - Tamaengs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: CtOSColors.primary,
          scaffoldBackgroundColor: CtOSColors.background,
          colorScheme: const ColorScheme.dark(
            primary: CtOSColors.primary,
            secondary: CtOSColors.secondary,
            surface: CtOSColors.surface,
            error: CtOSColors.error,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: HackerColors.text),
            bodyMedium: TextStyle(color: HackerColors.text),
            displayLarge: TextStyle(color: HackerColors.primary),
            displayMedium: TextStyle(color: HackerColors.primary),
            displaySmall: TextStyle(color: HackerColors.primary),
          ),
          fontFamily: 'Courier',
          // Perbaiki cardTheme dengan menghapus properti cardTheme
          cardColor: HackerColors.surface,
          // Ini yang menyebabkan error - menghapus cardTheme
          // Menggunakan cara yang lebih aman dengan fitur Material 3
          // (Versi Flutter yang lebih baru memiliki struktur ThemeData yang berbeda)
          // Dengan menghapus properti cardTheme dan menggunakan Material 3, Card akan mengambil
          // properti dari colorScheme yang sudah didefinisikan
          appBarTheme: const AppBarTheme(
            backgroundColor: HackerColors.surface,
            foregroundColor: HackerColors.primary,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: HackerColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: HackerColors.accent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: HackerColors.accent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: HackerColors.primary, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: HackerColors.text,
              backgroundColor: HackerColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        // Tambahkan routes untuk navigasi
        routes: {
          '/prodi/search': (context) => const ProdiSearchScreen(),
          '/dosen/search': (context) => const DosenSearchScreenNew(),
        },
        // Untuk routes yang membutuhkan parameter
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/prodi/detail/') ?? false) {
            final prodiId = settings.name!.split('/').last;
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ProdiDetailScreen(
                prodiId: prodiId,
                prodiName: args?['prodiName'] ?? 'Program Studi',
              ),
            );
          } else if (settings.name?.startsWith('/pt/detail/') ?? false) {
            final ptId = settings.name!.split('/').last;
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PTDetailScreen(
                ptId: ptId,
                ptName: args?['ptName'] ?? 'Institusi',
              ),
            );
          } else if (settings.name?.startsWith('/dosen/detail/') ?? false) {
            final dosenId = settings.name!.split('/').last;
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => DosenDetailScreen(
                dosenId: dosenId,
                dosenName: args?['dosenName'] ?? 'Dosen',
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
