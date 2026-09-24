import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl_io/home_screen.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PixelTheme.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Skribbl.io - Cute Pixel Edition',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: PixelTheme.bg,
            colorScheme: ColorScheme.fromSeed(
              seedColor: PixelTheme.primaryPink,
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: PixelTheme.primaryPink,
              secondary: PixelTheme.accentPurple,
            ),
            textTheme: GoogleFonts.silkscreenTextTheme(),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}