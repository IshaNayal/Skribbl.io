import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:skribbl_io/create_room_screen.dart';
import 'package:skribbl_io/join_room_screen.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/utils/room_code_generator.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;
  String? _invitedRoomCode;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Check if user followed an invite link (e.g. ?room=K9X2B7)
    if (kIsWeb) {
      try {
        final queryRoom = Uri.base.queryParameters['room'];
        if (queryRoom != null && queryRoom.trim().isNotEmpty) {
          _invitedRoomCode = RoomCodeGenerator.cleanCode(queryRoom);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PixelTheme.isDarkMode,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: PixelTheme.bg,
      body: Stack(
        children: [
          // Cute pixel decorative background elements
          Positioned(
            top: 20,
            left: 20,
            child: Text('🌸', style: TextStyle(fontSize: 28, color: Colors.pink.shade200)),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: Text('✨', style: TextStyle(fontSize: 26, color: Colors.amber.shade300)),
          ),
          Positioned(
            bottom: 40,
            left: 30,
            child: Text('🍓', style: TextStyle(fontSize: 28, color: Colors.pink.shade300)),
          ),
          Positioned(
            bottom: 60,
            right: 25,
            child: Text('💖', style: TextStyle(fontSize: 26, color: Colors.pink.shade300)),
          ),
          const Positioned(
            top: 14,
            right: 14,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PixelAudioToggle(height: 34, fontSize: 10),
                  SizedBox(width: 8),
                  PixelThemeToggle(height: 34, fontSize: 10),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Cute floating badge
                      AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -4 * _sparkleController.value),
                            child: child,
                          );
                        },
                        child: const PixelBadge(
                          label: '♥ PIXEL EDITION ♥',
                          backgroundColor: PixelTheme.accentYellow,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Pixel Game Title
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: PixelTheme.bgSurface,
                          border: PixelTheme.pixelBorder(width: 3.5),
                          boxShadow: PixelTheme.pixelShadow(offset: 4.5),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SKRIBBL.IO',
                              style: PixelTheme.pixelHeading(
                                fontSize: 30,
                                color: PixelTheme.primaryPink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create/Join a room to play!',
                              textAlign: TextAlign.center,
                              style: PixelTheme.pixel(
                                fontSize: 11,
                                color: PixelTheme.borderDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cute Mascot Window
                      PixelWindow(
                        title: 'Lets playyyyyy!!',
                        backgroundColor: PixelTheme.lightPastelPink,
                        padding: 16,
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🎀', style: TextStyle(fontSize: 24)),
                                SizedBox(width: 8),
                                Text('🎨', style: TextStyle(fontSize: 32)),
                                SizedBox(width: 8),
                                
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Draw cute things & guess with friends across the globe! 🌍',
                              textAlign: TextAlign.center,
                              style: PixelTheme.pixel(fontSize: 10, color: PixelTheme.borderDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // If user arrived via an invite link with ?room=CODE
                      if (_invitedRoomCode != null && _invitedRoomCode!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PixelTheme.accentYellow,
                            border: PixelTheme.pixelBorder(width: 2.5),
                            boxShadow: PixelTheme.pixelShadow(offset: 3),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '💌 YOU WERE INVITED TO ROOM: $_invitedRoomCode!',
                                style: PixelTheme.pixel(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PixelButton(
                                text: 'Join Room #$_invitedRoomCode',
                                fontSize: 11,
                                height: 38,
                                backgroundColor: PixelTheme.accentPurple,
                                textColor: Colors.white,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => JoinRoomScreen(initialRoomCode: _invitedRoomCode),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Action Buttons (Preserving "Create" & "Join" for tests)
                      Row(
                        children: [
                          Expanded(
                            child: PixelButton(
                              icon: const Text('🎮', style: TextStyle(fontSize: 16)),
                              text: 'Create',
                              backgroundColor: PixelTheme.primaryPink,
                              textColor: Colors.white,
                              height: 52,
                              fontSize: 14,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CreateRoomScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: PixelButton(
                              icon: const Text('🚪', style: TextStyle(fontSize: 16)),
                              text: 'Join',
                              backgroundColor: PixelTheme.accentPurple,
                              textColor: Colors.white,
                              height: 52,
                              fontSize: 14,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => JoinRoomScreen(initialRoomCode: _invitedRoomCode),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}