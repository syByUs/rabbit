import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';

/// Helper class for playing audio files
class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();
  static ProviderContainer? _providerContainer;

  /// Initialize the audio helper with provider container
  static void initialize(ProviderContainer container) {
    _providerContainer = container;
    _setupCompletionListener();
  }

  /// Setup listener for playback completion
  static void _setupCompletionListener() {
    _player.onPlayerComplete.listen((_) {
      // Reset playback state when audio completes
      if (_providerContainer != null) {
        _providerContainer!.read(audioPlaybackNotifierProvider.notifier).stop();
      }
    });
  }

  /// Play audio from assets
  static Future<void> playAsset(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  /// Play audio from URL
  static Future<void> playUrl(String url) async {
    await _player.play(UrlSource(url));
  }

  /// Play audio from local file
  static Future<void> playFile(String filePath) async {
    await _player.play(DeviceFileSource(filePath));
  }

  /// Pause current audio
  static Future<void> pause() async {
    await _player.pause();
  }

  /// Resume current audio
  static Future<void> resume() async {
    await _player.resume();
  }

  /// Stop current audio
  static Future<void> stop() async {
    await _player.stop();
  }

  /// Set volume (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  /// Seek to position
  static Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Dispose the player
  static Future<void> dispose() async {
    await _player.dispose();
  }

  /// Get player instance for advanced usage
  static AudioPlayer get player => _player;
}
