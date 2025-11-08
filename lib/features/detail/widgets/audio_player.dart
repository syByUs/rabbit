import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import 'audio_waveform.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioResource resource;

  const AudioPlayerWidget({
    super.key,
    required this.resource,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool isPlaying = false;
  String currentTime = '0:00';
  String totalTime = '0:00';

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _simulateProgress();
      }
    });
  }

  void _simulateProgress() {
    if (!isPlaying) return;

    int seconds = 0;
    const interval = Duration(seconds: 1);

    Future.delayed(interval, () {
      if (!mounted || !isPlaying) return;

      setState(() {
        seconds++;
        final minutes = seconds ~/ 60;
        final secs = seconds % 60;
        currentTime = '$minutes:${secs.toString().padLeft(2, '0')}';
      });

      _simulateProgress();
    });
  }

  void _rewind() {
    setState(() {
      currentTime = '0:00';
    });
    _showMessage('快退 5 秒');
  }

  void _forward() {
    _showMessage('快进 5 秒');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.audioPlayerDecoration,
      child: Column(
        children: [
          Text(
            widget.resource.title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 波形可视化
          const AudioWaveformWidget(),
          const SizedBox(height: AppSpacing.lg),

          // 播放控制
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.fast_rewind,
                onPressed: _rewind,
              ),
              const SizedBox(width: AppSpacing.md),
              _PlayButton(
                isPlaying: isPlaying,
                onPressed: _togglePlay,
              ),
              const SizedBox(width: AppSpacing.md),
              _ControlButton(
                icon: Icons.fast_forward,
                onPressed: _forward,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 时间显示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                totalTime,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.small,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: AppColors.textPrimary,
        onPressed: onPressed,
        splashRadius: 24.0,
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayButton({
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary500, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.large,
      ),
      child: IconButton(
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        color: Colors.white,
        iconSize: 32.0,
        onPressed: onPressed,
        splashRadius: 32.0,
      ),
    );
  }
}