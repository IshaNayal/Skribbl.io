import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_io/config.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';

class WaitingLobbyScreen extends StatefulWidget {
  final int occupancy;
  final int noOfPlayers;
  final String lobbyName;
  final List players;

  const WaitingLobbyScreen({
    super.key,
    required this.occupancy,
    required this.noOfPlayers,
    required this.lobbyName,
    required this.players,
  });

  @override
  State<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends State<WaitingLobbyScreen> {
  void _copyCodeOnly() {
    Clipboard.setData(ClipboardData(text: widget.lobbyName));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PixelTheme.primaryPink,
        content: Text(
          '📋 Room code ${widget.lobbyName} copied to clipboard! 💖',
          style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
        ),
      ),
    );
  }

  void _shareInvite() {
    final inviteLink = AppConfig.getInviteLink(widget.lobbyName);
    final text = '🎨 Join my Skribbl.io game!\n🏷️ Room Code: ${widget.lobbyName}\n🔗 Link: $inviteLink';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PixelTheme.accentMint,
        content: Text(
          '💌 Invite link & code copied! Share across the globe! 🌍',
          style: PixelTheme.pixel(fontSize: 11, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.occupancy - widget.noOfPlayers;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Status Badge
              Center(
                child: PixelBadge(
                  label: remaining > 0
                      ? '⏳ WAITING FOR $remaining PLAYER${remaining > 1 ? 'S' : ''}...'
                      : '✨ STARTING GAME! ✨',
                  backgroundColor: PixelTheme.accentYellow,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),

              // Global Room Code Ticket Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PixelTheme.lightPastelPink,
                  border: PixelTheme.pixelBorder(width: 3),
                  boxShadow: PixelTheme.pixelShadow(offset: 4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌍', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'GLOBAL ROOM CODE',
                          style: PixelTheme.pixel(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: PixelTheme.borderDark.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Big Bold Code Display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: PixelTheme.cardFill,
                        border: PixelTheme.pixelBorder(width: 2.5),
                        boxShadow: PixelTheme.pixelShadow(offset: 2),
                      ),
                      child: SelectableText(
                        widget.lobbyName,
                        textAlign: TextAlign.center,
                        style: PixelTheme.pixelHeading(
                          fontSize: 26,
                          color: PixelTheme.primaryPink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Copy & Share Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: PixelButton(
                            text: 'Copy Code',
                            icon: const Icon(Icons.copy, size: 14, color: Colors.white),
                            backgroundColor: PixelTheme.primaryPink,
                            textColor: Colors.white,
                            fontSize: 10,
                            height: 40,
                            onPressed: _copyCodeOnly,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PixelButton(
                            text: 'Share Link',
                            icon: const Icon(Icons.share, size: 14, color: Colors.black),
                            backgroundColor: PixelTheme.accentYellow,
                            textColor: Colors.black,
                            fontSize: 10,
                            height: 40,
                            onPressed: _shareInvite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anyone with this code can join your room!',
                      style: PixelTheme.pixel(fontSize: 9, color: PixelTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Roster Window
              PixelWindow(
                title: 'PLAYERS ROSTER (${widget.noOfPlayers}/${widget.occupancy})',
                backgroundColor: PixelTheme.bgSurface,
                padding: 14,
                child: Column(
                  children: List.generate(widget.occupancy, (index) {
                    final isFilled = index < widget.noOfPlayers;
                    if (isFilled) {
                      final player = widget.players[index];
                      final isLeader = player['isPartyLeader'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isLeader ? PixelTheme.babyPink : PixelTheme.cardFill,
                          border: PixelTheme.pixelBorder(width: 2),
                          boxShadow: PixelTheme.pixelShadow(offset: 2),
                        ),
                        child: Row(
                          children: [
                            Text(
                              isLeader ? '👑' : '🌸',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                player['nickname'] ?? 'Player',
                                style: PixelTheme.pixel(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            PixelBadge(
                              label: isLeader ? 'HOST' : 'READY',
                              backgroundColor: isLeader ? PixelTheme.accentYellow : PixelTheme.accentMint,
                              fontSize: 9,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: PixelTheme.inputFill,
                          border: Border.all(color: PixelTheme.borderDark.withValues(alpha: 0.2), width: 2),
                        ),
                        child: Row(
                          children: [
                            const Text('⏳', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Text(
                              'Waiting for player ${index + 1}...',
                              style: PixelTheme.pixel(
                                fontSize: 11,
                                color: PixelTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}