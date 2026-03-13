import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartClassApp());
}

class SmartClassApp extends StatelessWidget {
  const SmartClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2962FF),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Smart Class Check-in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF2F6FF),
        textTheme: ThemeData.light().textTheme.copyWith(
          headlineMedium: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(fontSize: 16),
          bodyMedium: const TextStyle(fontSize: 14.5),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return 1;
              }

              if (states.contains(WidgetState.hovered)) {
                return 10;
              }

              return 4;
            }),
            shadowColor: WidgetStateProperty.all(
              const Color(0x402962FF),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.82),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}