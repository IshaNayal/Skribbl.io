import 'package:flutter/material.dart';
import 'package:skribbl_io/home_screen.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';

class FinalLeaderboard extends StatelessWidget {
  final List<Map> scoreboard;
  final String winner;
  const FinalLeaderboard(this.scoreboard, this.winner, {super.key});

  @override
  Widget build(BuildContext context) {
    // Sort descending by points
    final sorted = List<Map>.from(scoreboard);
    sorted.sort((a, b) {
      final pA = int.tryParse(a['points']?.toString() ?? '0') ?? 0;
      final pB = int.tryParse(b['points']?.toString() ?? '0') ?? 0;
      return pB.compareTo(pA);
    });

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebration Banner
              Center(
                child: PixelBadge(
                  label: '🎉 GAME COMPLETED! 🎉',
                  backgroundColor: PixelTheme.accentYellow,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // Winner Announcement Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PixelTheme.primaryPink,
                  border: PixelTheme.pixelBorder(width: 3.5),
                  boxShadow: PixelTheme.pixelShadow(offset: 4.5),
                ),
                child: Column(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 6),
                    Text(
                      winner.isNotEmpty ? winner : 'PLAYER',
                      textAlign: TextAlign.center,
                      style: PixelTheme.pixelHeading(fontSize: 26, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'IS THE DRAWING CHAMPION! 💖',
                      textAlign: TextAlign.center,
                      style: PixelTheme.pixel(fontSize: 12, color: PixelTheme.accentYellow, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Final Standings Window
              PixelWindow(
                title: 'FINAL STANDINGS',
                backgroundColor: PixelTheme.bgSurface,
                padding: 14,
                child: Column(
                  children: List.generate(sorted.length, (index) {
                    final player = sorted[index];
                    final name = player['username'] ?? 'Player';
                    final points = player['points'] ?? '0';

                    String medal = '${index + 1}.';
                    Color cardBg = PixelTheme.cardFill;
                    if (index == 0) {
                      medal = '🥇';
                      cardBg = PixelTheme.accentYellow.withValues(alpha: 0.3);
                    } else if (index == 1) {
                      medal = '🥈';
                    } else if (index == 2) {
                      medal = '🥉';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: PixelTheme.pixelBorder(width: 2),
                        boxShadow: PixelTheme.pixelShadow(offset: 2),
                      ),
                      child: Row(
                        children: [
                          Text(medal, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              style: PixelTheme.pixel(fontSize: 13, fontWeight: FontWeight.bold),
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
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Play Again Button
              PixelButton(
                text: 'PLAY AGAIN ✨',
                backgroundColor: PixelTheme.accentMint,
                textColor: PixelTheme.borderDark,
                height: 52,
                fontSize: 15,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}