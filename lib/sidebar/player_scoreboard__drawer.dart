import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';

class PlayerScore extends StatelessWidget {
  final List<Map> userData;
  final String? roomCode;

  const PlayerScore(this.userData, {super.key, this.roomCode});

  @override
  Widget build(BuildContext context) {
    // Sort players by points descending
    final sortedData = List<Map>.from(userData);
    sortedData.sort((a, b) {
      final pA = int.tryParse(a['points']?.toString() ?? '0') ?? 0;
      final pB = int.tryParse(b['points']?.toString() ?? '0') ?? 0;
      return pB.compareTo(pA);
    });

    return Drawer(
      backgroundColor: PixelTheme.bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: PixelTheme.primaryPink,
                border: Border(
                  bottom: BorderSide(color: PixelTheme.borderDark, width: 3),
                ),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'SCOREBOARD',
                    style: PixelTheme.pixelHeading(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Player List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sortedData.length,
                itemBuilder: (context, index) {
                  final player = sortedData[index];
                  final username = player['username'] ?? 'Player';
                  final points = player['points'] ?? '0';

                  String rankIcon = '🌸';
                  Color cardBg = PixelTheme.cardFill;
                  if (index == 0) {
                    rankIcon = '👑';
                    cardBg = PixelTheme.accentYellow.withValues(alpha: 0.35);
                  } else if (index == 1) {
                    rankIcon = '🥈';
                  } else if (index == 2) {
                    rankIcon = '🥉';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: PixelTheme.pixelBorder(width: 2.5),
                      boxShadow: PixelTheme.pixelShadow(offset: 2.5),
                    ),
                    child: Row(
                      children: [
                        Text(rankIcon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            username,
                            style: PixelTheme.pixel(fontSize: 13, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PixelBadge(
                          label: '$points PTS',
                          backgroundColor: PixelTheme.babyPink,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Room Code quick copy badge
            if (roomCode != null && roomCode!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: roomCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: PixelTheme.primaryPink,
                        content: Text(
                          '📋 Room code $roomCode copied! 💖',
                          style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: PixelTheme.cardFill,
                      border: PixelTheme.pixelBorder(width: 2),
                      boxShadow: PixelTheme.pixelShadow(offset: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 14, color: PixelTheme.borderDark),
                        const SizedBox(width: 6),
                        Text(
                          'ROOM: $roomCode (COPY)',
                          style: PixelTheme.pixel(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Theme toggle
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: PixelThemeToggle(height: 42, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}