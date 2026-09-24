import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl_io/create_room_screen.dart';
import 'package:skribbl_io/home_screen.dart';
import 'package:skribbl_io/join_room_screen.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';

void main() {
  if (kIsWeb) {
    try {
      final theme = Uri.base.queryParameters['theme'];
      if (theme == 'dark') {
        PixelTheme.isDarkMode.value = true;
      }
    } catch (_) {}
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget home = const HomeScreen();
    if (kIsWeb) {
      try {
        final screen = Uri.base.queryParameters['screen'];
        if (screen == 'create') {
          home = const CreateRoomScreen();
        } else if (screen == 'join') {
          home = const JoinRoomScreen();
        }
      } catch (_) {}
    }

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
          home: home,
        );
      },
    );
  }
}