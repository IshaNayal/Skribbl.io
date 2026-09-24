import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_io/paint_screen.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/utils/room_code_generator.dart';
import 'package:skribbl_io/widgets/custom_text_field.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';

class JoinRoomScreen extends StatefulWidget {
  final String? initialRoomCode;
  const JoinRoomScreen({super.key, this.initialRoomCode});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRoomCode != null && widget.initialRoomCode!.trim().isNotEmpty) {
      _roomNameController.text = RoomCodeGenerator.cleanCode(widget.initialRoomCode!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _pasteCode() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.trim().isNotEmpty) {
        final cleaned = RoomCodeGenerator.cleanCode(clipboardData.text!);
        if (cleaned.isNotEmpty) {
          setState(() {
            _roomNameController.text = cleaned;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: PixelTheme.accentPurple,
                content: Text(
                  '📋 Pasted room code: $cleaned! 💖',
                  style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
                ),
              ),
            );
          }
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PixelTheme.primaryPink,
          content: Text(
            '⚠️ Clipboard is empty or contains no room code!',
            style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
          ),
        ),
      );
    }
  }

  void joinRoom() {
    final cleanCode = RoomCodeGenerator.cleanCode(_roomNameController.text);
    if (_nameController.text.trim().isNotEmpty && cleanCode.isNotEmpty) {
      Map<String, String> data = {
        "nickname": _nameController.text.trim(),
        "name": cleanCode,
      };

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaintScreen(data: data, screenFrom: 'joinRoom'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PixelTheme.primaryPink,
          content: Text(
            '★ Please enter nickname and room code! ★',
            style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PixelTheme.isDarkMode,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: PixelTheme.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
              child: PixelButton(
                text: '< BACK',
                fontSize: 10,
                height: 36,
                backgroundColor: PixelTheme.bgSurface,
                textColor: PixelTheme.borderDark,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: PixelAudioToggle(height: 36, fontSize: 10),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(right: 14, top: 8, bottom: 8),
                child: PixelThemeToggle(height: 36, fontSize: 10),
              ),
            ],
          ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: PixelWindow(
              title: 'ENTER LOBBY ★',
              backgroundColor: PixelTheme.bgSurface,
              padding: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'JOIN ROOM',
                      style: PixelTheme.pixelHeading(
                        fontSize: 22,
                        color: PixelTheme.accentPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('YOUR NICKNAME 💖', style: PixelTheme.pixel(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: _nameController,
                    hintText: "Enter cute name...",
                    prefixIcon: const Icon(Icons.face, color: PixelTheme.accentPurple, size: 20),
                  ),
                  const SizedBox(height: 16),

                  // Room Code Header with Paste button
                  Row(
                    children: [
                      Text('ROOM CODE 🏷️', style: PixelTheme.pixel(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _pasteCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PixelTheme.accentYellow,
                            border: PixelTheme.pixelBorder(width: 1.5),
                            boxShadow: PixelTheme.pixelShadow(offset: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.paste, size: 12, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                'PASTE',
                                style: PixelTheme.pixel(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Room code input field with paste button
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _roomNameController,
                          hintText: "e.g. K9X2B7",
                          textCapitalization: TextCapitalization.characters,
                          prefixIcon: const Icon(Icons.meeting_room, color: PixelTheme.accentPurple, size: 20),
                          style: PixelTheme.pixel(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Paste from clipboard',
                        child: GestureDetector(
                          onTap: _pasteCode,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: PixelTheme.accentYellow,
                              border: PixelTheme.pixelBorder(width: 2.5),
                              boxShadow: PixelTheme.pixelShadow(offset: 2.5),
                            ),
                            child: const Center(
                              child: Icon(Icons.paste, size: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🌍 Enter the 6-character code created by the host across the globe!',
                    style: PixelTheme.pixel(fontSize: 9, color: PixelTheme.textMuted),
                  ),
                  const SizedBox(height: 28),

                  PixelButton(
                    text: 'Join',
                    icon: const Text('💖', style: TextStyle(fontSize: 16)),
                    backgroundColor: PixelTheme.accentPurple,
                    textColor: Colors.white,
                    height: 52,
                    fontSize: 15,
                    onPressed: joinRoom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
  }
}