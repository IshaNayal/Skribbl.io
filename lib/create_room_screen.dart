import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_io/paint_screen.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/utils/room_code_generator.dart';
import 'package:skribbl_io/widgets/custom_text_field.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  String? _maxRoundsValue = "2";
  String? _roomSizeValue = "2";

  @override
  void initState() {
    super.initState();
    // Automatically generate a 6-character alphanumeric room code
    _roomNameController.text = RoomCodeGenerator.generate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  void _regenerateCode() {
    setState(() {
      _roomNameController.text = RoomCodeGenerator.generate();
    });
  }

  void _copyCode() {
    final code = RoomCodeGenerator.cleanCode(_roomNameController.text);
    if (code.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PixelTheme.primaryPink,
          content: Text(
            '📋 Room code $code copied to clipboard! 💖',
            style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
          ),
        ),
      );
    }
  }

  void createRoom() {
    final cleanCode = RoomCodeGenerator.cleanCode(_roomNameController.text);
    if (_nameController.text.trim().isNotEmpty &&
        cleanCode.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text.trim(),
        "name": cleanCode,
        "occupancy": _roomSizeValue!,
        "maxRounds": _maxRoundsValue!,
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: 'createRoom'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PixelTheme.primaryPink,
          content: Text(
            '★ Please enter nickname and a valid room code! ★',
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
              title: 'HOST NEW GAME ★',
              backgroundColor: PixelTheme.bgSurface,
              padding: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'CREATE ROOM',
                      style: PixelTheme.pixelHeading(
                        fontSize: 22,
                        color: PixelTheme.primaryPink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text('YOUR NICKNAME 💖', style: PixelTheme.pixel(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: _nameController,
                    hintText: "Enter cute name...",
                    prefixIcon: const Icon(Icons.face, color: PixelTheme.primaryPink, size: 20),
                  ),
                  const SizedBox(height: 16),

                  // Room Code Header with Auto-Generated tag
                  Row(
                    children: [
                      Text('ROOM CODE 🏷️', style: PixelTheme.pixel(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: PixelTheme.babyPink,
                          border: PixelTheme.pixelBorder(width: 1.5),
                        ),
                        child: Text(
                          'AUTO-GENERATED',
                          style: PixelTheme.pixel(fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Room code input with dice roll & copy buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _roomNameController,
                          hintText: "e.g. K9X2B7",
                          textCapitalization: TextCapitalization.characters,
                          prefixIcon: const Icon(Icons.tag, color: PixelTheme.primaryPink, size: 20),
                          style: PixelTheme.pixel(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Re-roll button
                      Tooltip(
                        message: 'Generate new random code',
                        child: GestureDetector(
                          onTap: _regenerateCode,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: PixelTheme.accentYellow,
                              border: PixelTheme.pixelBorder(width: 2.5),
                              boxShadow: PixelTheme.pixelShadow(offset: 2.5),
                            ),
                            child: const Center(child: Text('🎲', style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Copy code button
                      Tooltip(
                        message: 'Copy code to clipboard',
                        child: GestureDetector(
                          onTap: _copyCode,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: PixelTheme.accentMint,
                              border: PixelTheme.pixelBorder(width: 2.5),
                              boxShadow: PixelTheme.pixelShadow(offset: 2.5),
                            ),
                            child: const Center(child: Icon(Icons.copy, size: 20, color: Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🌍 Share this code with friends so they can join from anywhere!',
                    style: PixelTheme.pixel(fontSize: 9, color: PixelTheme.textMuted),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ROUNDS 🎯', style: PixelTheme.pixel(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            _buildPixelDropdown(
                              value: _maxRoundsValue,
                              items: ["2", "5", "10", "15"],
                              onChanged: (val) => setState(() => _maxRoundsValue = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MAX PLAYERS 👥', style: PixelTheme.pixel(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            _buildPixelDropdown(
                              value: _roomSizeValue,
                              items: ["2", "3", "4", "5", "6", "7", "8"],
                              onChanged: (val) => setState(() => _roomSizeValue = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  PixelButton(
                    text: 'Create',
                    icon: const Text('✨', style: TextStyle(fontSize: 16)),
                    backgroundColor: PixelTheme.primaryPink,
                    textColor: Colors.white,
                    height: 52,
                    fontSize: 15,
                    onPressed: createRoom,
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

  Widget _buildPixelDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: PixelTheme.inputFill,
        border: PixelTheme.pixelBorder(width: 2.5),
        boxShadow: PixelTheme.pixelShadow(offset: 2.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: PixelTheme.inputFill,
          icon: Icon(Icons.arrow_drop_down, color: PixelTheme.borderDark),
          style: PixelTheme.pixel(fontSize: 12, color: PixelTheme.borderDark),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: PixelTheme.pixel(fontSize: 12)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
