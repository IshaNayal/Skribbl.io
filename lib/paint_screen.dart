import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_io/config.dart';
import 'package:skribbl_io/final_leaderboard.dart';
import 'package:skribbl_io/home_screen.dart';
import 'package:skribbl_io/models/my_custom_painter.dart';
import 'package:skribbl_io/models/touch_points.dart';
import 'package:skribbl_io/sidebar/player_scoreboard__drawer.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';
import 'package:skribbl_io/waiting_lobby_screen.dart';
import 'package:skribbl_io/widgets/pixel_widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  const PaintScreen({super.key, required this.data, required this.screenFrom});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late io.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints?> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  List<Map> messages = [];
  int guessedUserCtr = 0;
  int _start = 60;
  Timer? _timer;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;
  String? connectionError;

  // Preset cute pixel art drawing palette
  static const List<Color> _palette = [
    Colors.black,
    PixelTheme.primaryPink,
    Color(0xFFE63946), // Cherry red
    Color(0xFFF4A261), // Coral
    Color(0xFFFFE066), // Butter yellow
    Color(0xFF7AE582), // Mint green
    Color(0xFF48CAE4), // Sky blue
    Color(0xFFC77DFF), // Lilac
    Color(0xFF6F4E37), // Chocolate
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    _timer?.cancel();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        time.cancel();
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '_',
            style: PixelTheme.pixelHeading(fontSize: 26, color: PixelTheme.primaryPink),
          ),
        ),
      );
    }
  }

  void connect() {
    final serverUrl = AppConfig.serverUrl;
    _socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false
    });
    _socket.connect();

    _socket.onConnectError((err) {
      if (!mounted) return;
      setState(() {
        connectionError =
            'Could not connect to server at $serverUrl.\n\nMake sure the Node backend server is running.';
      });
    });

    _socket.onConnectTimeout((_) {
      if (!mounted) return;
      setState(() {
        connectionError =
            'Connection to $serverUrl timed out.\n\nMake sure the backend is reachable on your network.';
      });
    });

    _socket.onConnect((data) {
      if (!mounted) return;
      setState(() {
        connectionError = null;
      });

      if (widget.screenFrom == 'createRoom') {
        _socket.emit('create-game', widget.data);
      } else {
        _socket.emit('join-game', widget.data);
      }

      _socket.on('updateRoom', (roomData) {
        if (!mounted) return;
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          if (!mounted) return;
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on('notCorrectGame', (data) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PixelTheme.primaryPink,
            content: Text(data.toString(), style: PixelTheme.pixel(fontSize: 11, color: Colors.white)),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      });

      _socket.on('points', (point) {
        if (!mounted) return;
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withValues(alpha: opacity)
                  ..strokeWidth = strokeWidth));
          });
        } else {
          setState(() {
            points.add(null);
          });
        }
      });

      _socket.on('msg', (msgData) {
        if (!mounted) return;
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if (guessedUserCtr == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 40,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        }
      });

      _socket.on('change-turn', (data) {
        if (!mounted) return;
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              Future.delayed(const Duration(seconds: 3), () {
                if (!mounted) return;
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  isTextInputReadOnly = false;
                  guessedUserCtr = 0;
                  _start = 60;
                  points.clear();
                });
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                _timer?.cancel();
                startTimer();
              });
              return AlertDialog(
                backgroundColor: PixelTheme.bgSurface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: PixelTheme.borderDark, width: 3),
                ),
                title: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⏰ TIME\'S UP! ⏰', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      Text(
                        'WORD WAS: $oldWord',
                        style: PixelTheme.pixelHeading(fontSize: 16, color: PixelTheme.primaryPink),
                      ),
                    ],
                  ),
                ),
              );
            });
      });

      _socket.on('updateScore', (roomData) {
        if (!mounted) return;
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on("show-leaderboard", (roomPlayers) {
        if (!mounted) return;
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          scoreboard.add({
            'username': roomPlayers[i]['nickname'],
            'points': roomPlayers[i]['points'].toString()
          });
          int currentPoints = int.tryParse(scoreboard[i]['points']) ?? 0;
          if (winner.isEmpty || currentPoints >= maxPoints) {
            winner = scoreboard[i]['username'];
            maxPoints = currentPoints;
          }
        }
        setState(() {
          _timer?.cancel();
          isShowFinalLeaderboard = true;
        });
      });

      _socket.on('color-change', (colorString) {
        if (!mounted) return;
        int value = int.parse(colorString.toString(), radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });

      _socket.on('stroke-width', (value) {
        if (!mounted) return;
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clear-screen', (data) {
        if (!mounted) return;
        setState(() {
          points.clear();
        });
      });

      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name']);
        if (!mounted) return;
        setState(() {
          isTextInputReadOnly = true;
        });
      });

      _socket.on('user-disconnected', (data) {
        if (!mounted) return;
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'].toString()
            });
          });
        }
      });
    });
  }

  void _sendColor(Color color) {
    setState(() {
      selectedColor = color;
    });
    String valueString = color.toARGB32().toRadixString(16);
    Map map = {
      'color': valueString,
      'roomName': dataOfRoom['name']
    };
    _socket.emit('color-change', map);
  }

  void _submitGuess() {
    final value = controller.text.trim();
    if (value.isNotEmpty) {
      Map map = {
        'username': widget.data['nickname'],
        'msg': value,
        'word': dataOfRoom['word'],
        'roomName': widget.data['name'],
        'guessedUserCtr': guessedUserCtr,
        'totalTime': 60,
        'timeTaken': 60 - _start,
      };
      _socket.emit('msg', map);
      controller.clear();
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer?.cancel();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (connectionError != null) {
      return Scaffold(
        backgroundColor: PixelTheme.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: PixelWindow(
              title: '★ CONNECTION ERROR ★',
              backgroundColor: PixelTheme.bgSurface,
              padding: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔌', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    connectionError!,
                    textAlign: TextAlign.center,
                    style: PixelTheme.pixel(fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  PixelButton(
                    text: 'RETRY 🔄',
                    backgroundColor: PixelTheme.accentMint,
                    textColor: PixelTheme.borderDark,
                    onPressed: () {
                      setState(() {
                        connectionError = null;
                      });
                      _socket.connect();
                    },
                  ),
                  const SizedBox(height: 10),
                  PixelButton(
                    text: 'BACK TO HOME 🏠',
                    backgroundColor: PixelTheme.babyPink,
                    textColor: PixelTheme.borderDark,
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
        ),
      );
    }

    void selectColorPicker() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: PixelTheme.bgSurface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: PixelTheme.borderDark, width: 3),
          ),
          title: Text('★ CHOOSE COLOR ★', style: PixelTheme.pixel(fontSize: 13, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                _sendColor(color);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    }

    final isMyTurn = dataOfRoom.isNotEmpty &&
        dataOfRoom['turn'] != null &&
        dataOfRoom['turn']['nickname'] == widget.data['nickname'];

    return ValueListenableBuilder<bool>(
      valueListenable: PixelTheme.isDarkMode,
      builder: (context, isDark, _) {
        return Scaffold(
          key: scaffoldKey,
          drawer: PlayerScore(scoreboard, roomCode: dataOfRoom['name']?.toString()),
      backgroundColor: PixelTheme.bg,
      body: dataOfRoom.isNotEmpty
          ? dataOfRoom['isJoin'] != true
              ? !isShowFinalLeaderboard
                  ? SafeArea(
                      child: Column(
                        children: [
                          // Top Status Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                // Players Drawer Button
                                PixelButton(
                                  text: '👥',
                                  fontSize: 14,
                                  height: 38,
                                  width: 44,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: PixelTheme.babyPink,
                                  textColor: PixelTheme.borderDark,
                                  onPressed: () => scaffoldKey.currentState!.openDrawer(),
                                ),
                                const SizedBox(width: 8),

                                // Room Code Tap-to-Copy Chip
                                GestureDetector(
                                  onTap: () {
                                    final code = dataOfRoom['name']?.toString() ?? '';
                                    if (code.isNotEmpty) {
                                      Clipboard.setData(ClipboardData(text: code));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: PixelTheme.primaryPink,
                                          content: Text(
                                            '📋 Room code $code copied! 💖',
                                            style: PixelTheme.pixel(fontSize: 11, color: Colors.white),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: PixelBadge(
                                    label: '#${dataOfRoom['name'] ?? ''}',
                                    backgroundColor: PixelTheme.accentYellow,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Round Badge
                                Expanded(
                                  child: Center(
                                    child: PixelBadge(
                                      label: 'ROUND ${dataOfRoom['currentRound'] ?? 1}/${dataOfRoom['maxRounds'] ?? 2}',
                                      backgroundColor: PixelTheme.accentPurple.withValues(alpha: 0.3),
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Timer Badge
                                PixelBadge(
                                  label: '⏰ ${_start}s',
                                  backgroundColor: _start <= 10 ? PixelTheme.primaryPink : PixelTheme.accentYellow,
                                  textColor: _start <= 10 ? Colors.white : PixelTheme.borderDark,
                                  fontSize: 10,
                                ),
                                const SizedBox(width: 8),

                                // Audio Toggle
                                const PixelAudioToggle(height: 38, fontSize: 8),
                                const SizedBox(width: 8),

                                // Dark Mode Toggle
                                const PixelThemeToggle(height: 38, fontSize: 8),
                              ],
                            ),
                          ),

                          // Prompt Banner (Secret word or blank dashes)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMyTurn ? PixelTheme.primaryPink : PixelTheme.bgSurface,
                              border: PixelTheme.pixelBorder(width: 2.5),
                              boxShadow: PixelTheme.pixelShadow(offset: 2.5),
                            ),
                            child: isMyTurn
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🎨', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'DRAW: ${dataOfRoom['word'].toString().toUpperCase()}',
                                        style: PixelTheme.pixelHeading(fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('💭', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: textBlankWidget,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${dataOfRoom['word'].toString().length})',
                                        style: PixelTheme.pixel(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                          ),

                          // The Drawing Canvas Frame
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: PixelTheme.pixelBorder(width: 3.5),
                                  boxShadow: PixelTheme.pixelShadow(offset: 4),
                                ),
                                child: ClipRect(
                                  child: GestureDetector(
                                    onPanUpdate: isMyTurn
                                        ? (details) {
                                            _socket.emit('paint', {
                                              'details': {
                                                'dx': details.localPosition.dx,
                                                'dy': details.localPosition.dy,
                                              },
                                              'roomName': widget.data['name'],
                                            });
                                          }
                                        : null,
                                    onPanStart: isMyTurn
                                        ? (details) {
                                            _socket.emit('paint', {
                                              'details': {
                                                'dx': details.localPosition.dx,
                                                'dy': details.localPosition.dy,
                                              },
                                              'roomName': widget.data['name'],
                                            });
                                          }
                                        : null,
                                    onPanEnd: isMyTurn
                                        ? (details) {
                                            _socket.emit('paint', {
                                              'details': null,
                                              'roomName': widget.data['name'],
                                            });
                                          }
                                        : null,
                                    child: CustomPaint(
                                      size: Size.infinite,
                                      painter: MyCustomPainter(pointsList: points),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Drawer Tools (Palette, Brush slider, Clear)
                          if (isMyTurn) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: PixelTheme.bgSurface,
                                border: PixelTheme.pixelBorder(width: 2),
                              ),
                              child: Column(
                                children: [
                                  // Color palette swatches
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ..._palette.map((c) {
                                        final isSelected = selectedColor.toARGB32() == c.toARGB32();
                                        return GestureDetector(
                                          onTap: () => _sendColor(c),
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: c,
                                              border: Border.all(
                                                color: isSelected ? PixelTheme.primaryPink : PixelTheme.borderDark,
                                                width: isSelected ? 3 : 1.5,
                                              ),
                                              boxShadow: isSelected
                                                  ? [BoxShadow(color: PixelTheme.borderDark, offset: const Offset(1.5, 1.5))]
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }),
                                      GestureDetector(
                                        onTap: selectColorPicker,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: PixelTheme.babyPink,
                                            border: Border.all(color: PixelTheme.borderDark, width: 1.5),
                                          ),
                                          child: const Text('🎨+', style: TextStyle(fontSize: 10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Stroke width & Clear button
                                  Row(
                                    children: [
                                      PixelBadge(label: '${strokeWidth.toInt()}px', fontSize: 9),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            activeTrackColor: PixelTheme.primaryPink,
                                            inactiveTrackColor: PixelTheme.babyPink,
                                            thumbColor: PixelTheme.primaryPink,
                                            trackHeight: 4,
                                          ),
                                          child: Slider(
                                            min: 1.0,
                                            max: 12.0,
                                            value: strokeWidth,
                                            onChanged: (double value) {
                                              Map map = {
                                                'value': value,
                                                'roomName': dataOfRoom['name']
                                              };
                                              _socket.emit('stroke-width', map);
                                            },
                                          ),
                                        ),
                                      ),
                                      PixelButton(
                                        text: 'CLEAR 🗑️',
                                        fontSize: 9,
                                        height: 30,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        backgroundColor: PixelTheme.babyPink,
                                        textColor: PixelTheme.borderDark,
                                        onPressed: () {
                                          _socket.emit('clean-screen', dataOfRoom['name']);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Chat Log & Guess Input
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: PixelTheme.bgSurface,
                                  border: PixelTheme.pixelBorder(width: 2.5),
                                  boxShadow: PixelTheme.pixelShadow(offset: 2.5),
                                ),
                                child: Column(
                                  children: [
                                    // Chat header
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      color: PixelTheme.babyPink,
                                      child: Row(
                                        children: [
                                          const Text('💬', style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'GUESS CHAT (${messages.length})',
                                            style: PixelTheme.pixel(fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Chat messages
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(8),
                                        itemCount: messages.length,
                                        itemBuilder: (context, index) {
                                          final item = messages[index];
                                          final user = item['username'] ?? '';
                                          final text = item['msg'] ?? '';
                                          final isCorrect = text == 'Guessed it!';

                                          if (isCorrect) {
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: PixelTheme.accentMint.withValues(alpha: 0.35),
                                                border: Border.all(color: PixelTheme.accentMint, width: 1.5),
                                              ),
                                              child: Text(
                                                '✨ $user GUESSED IT! 🎉',
                                                style: PixelTheme.pixel(
                                                  fontSize: 10,
                                                  color: PixelTheme.borderDark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 3),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '$user: ',
                                                    style: PixelTheme.pixel(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: PixelTheme.primaryPink,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: text,
                                                    style: PixelTheme.pixel(
                                                      fontSize: 11,
                                                      color: PixelTheme.borderDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // Guess Input bar (for guessers)
                                    if (!isMyTurn) ...[
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: PixelTheme.borderDark, width: 2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: isTextInputReadOnly ? Colors.grey.shade200 : PixelTheme.inputFill,
                                                  border: PixelTheme.pixelBorder(width: 2),
                                                ),
                                                child: TextField(
                                                  readOnly: isTextInputReadOnly,
                                                  controller: controller,
                                                  onSubmitted: (_) => _submitGuess(),
                                                  style: PixelTheme.pixel(fontSize: 12),
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    border: InputBorder.none,
                                                    hintText: isTextInputReadOnly
                                                        ? 'You already guessed! ✨'
                                                        : 'Your guess here... 💭',
                                                    hintStyle: PixelTheme.pixel(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            PixelButton(
                                              text: 'SEND',
                                              fontSize: 10,
                                              height: 38,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              backgroundColor: PixelTheme.primaryPink,
                                              textColor: Colors.white,
                                              onPressed: isTextInputReadOnly ? null : _submitGuess,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : FinalLeaderboard(scoreboard, winner)
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : Scaffold(
              backgroundColor: PixelTheme.bg,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌸', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 14),
                    Text(
                      'LOADING ROOM...',
                      style: PixelTheme.pixel(fontSize: 13, color: PixelTheme.primaryPink, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }
}