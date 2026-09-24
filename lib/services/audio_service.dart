import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Global service managing retro 8-bit background music in loop
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();

  final ValueNotifier<bool> isMusicPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

  bool _initialized = false;
  final double _defaultVolume = 0.35;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_defaultVolume);

      _player.onPlayerStateChanged.listen((state) {
        isMusicPlaying.value = (state == PlayerState.playing);
      });

      // Try initial playback; web browsers will suspend until first user tap
      await playBgm();
    } catch (e) {
      debugPrint('Audio initialization notice: $e');
    }
  }

  Future<void> playBgm() async {
    if (isMuted.value) return;
    try {
      if (_player.state != PlayerState.playing) {
        try {
          await _player.play(AssetSource('audio/bgm.mp3'));
        } catch (_) {
          await _player.play(AssetSource('assets/audio/bgm.mp3'));
        }
        isMusicPlaying.value = true;
      }
    } catch (e) {
      // Browser autoplay restriction waiting for interaction
      debugPrint('Audio awaiting user interaction: $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _player.pause();
      isMusicPlaying.value = false;
    } catch (e) {
      debugPrint('Audio pause error: $e');
    }
  }

  Future<void> toggleMute() async {
    if (isMuted.value) {
      // Unmute
      isMuted.value = false;
      await _player.setVolume(_defaultVolume);
      await playBgm();
    } else {
      // Mute
      isMuted.value = true;
      await _player.pause();
      isMusicPlaying.value = false;
    }
  }

  /// Automatically starts BGM on the first user click/tap (satisfies Web autoplay policy)
  void onUserInteraction() {
    if (!isMuted.value && !isMusicPlaying.value) {
      playBgm();
    }
  }
}
