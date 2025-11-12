import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/audio_segment_model.dart';

class ControlDisplayWidget extends StatefulWidget {
  final AudioSegment segment;
  final bool isPlaying;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPlayToggle;

  const ControlDisplayWidget({
    super.key,
    required this.segment,
    required this.isPlaying,
    this.onPrevious,
    this.onNext,
    required this.onPlayToggle,
  });

  @override
  State<ControlDisplayWidget> createState() => _ControlDisplayWidgetState();
}

class _ControlDisplayWidgetState extends State<ControlDisplayWidget> {
  bool isLoopEnabled = false;
  bool isRandomEnabled = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              icon: Icons.fast_rewind,
              onPressed: widget.onPrevious != null
                  ? () {
                      widget.onPrevious!();
                      _showMessage('上一段');
                    }
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            _PlayButton(
              isPlaying: widget.isPlaying,
              onPressed: widget.onPlayToggle,
            ),
            const SizedBox(width: AppSpacing.md),
            _ControlButton(
              icon: Icons.fast_forward,
              onPressed: widget.onNext != null
                  ? () {
                      widget.onNext!();
                      _showMessage('下一段');
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SettingsItem(
              icon: Icons.loop,
              label: '循环',
              isActive: isLoopEnabled,
              onTap: () {
                setState(() {
                  isLoopEnabled = !isLoopEnabled;
                });
                _showMessage(isLoopEnabled ? '循环模式已开启' : '循环模式已关闭');
              },
            ),
            Column(
              children: [
                Text(
                  widget.segment.timeRange,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            _SettingsItem(
              icon: Icons.shuffle,
              label: '随机',
              isActive: isRandomEnabled,
              onTap: () {
                setState(() {
                  isRandomEnabled = !isRandomEnabled;
                });
                _showMessage(isRandomEnabled ? '随机播放已开启' : '随机播放已关闭');
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64.0,
        child: Column(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary50 : AppColors.neutral0,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isActive ? AppColors.primary500 : AppColors.neutral200,
                ),
              ),
              child: Icon(
                icon,
                size: 20.0,
                color: isActive ? AppColors.primary500 : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}