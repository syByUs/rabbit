import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

/// 高级设置对话框
/// 允许 PRO 用户自定义静音检测参数
class AdvancedSettingsDialog extends StatefulWidget {
  final double initialSilenceDuration;
  final double initialSilenceThreshold;

  const AdvancedSettingsDialog({
    super.key,
    this.initialSilenceDuration = 0.6,
    this.initialSilenceThreshold = -40.0,
  });

  @override
  State<AdvancedSettingsDialog> createState() => _AdvancedSettingsDialogState();
}

class _AdvancedSettingsDialogState extends State<AdvancedSettingsDialog> {
  late double silenceDuration;
  late double silenceThreshold;

  @override
  void initState() {
    super.initState();
    silenceDuration = widget.initialSilenceDuration;
    silenceThreshold = widget.initialSilenceThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Text(
                  '💎',
                  style: TextStyle(fontSize: 24.0),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '高级设置',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '自定义静音检测参数以获得最佳分割效果',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 静音时长阈值设置
            _buildSettingSection(
              title: '静音时长阈值',
              description: '检测为静音所需的最短持续时间',
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSlider(
              value: silenceDuration,
              min: 0.3,
              max: 2.0,
              divisions: 17,
              label: '${silenceDuration.toStringAsFixed(1)}秒',
              onChanged: (value) => setState(() => silenceDuration = value),
            ),
            _buildValueDisplay('${silenceDuration.toStringAsFixed(1)} 秒'),

            const SizedBox(height: AppSpacing.xl),

            // 静音分贝阈值设置
            _buildSettingSection(
              title: '静音分贝阈值',
              description: '音量低于此值时视为静音',
              icon: Icons.volume_down_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSlider(
              value: -silenceThreshold,
              min: 30,
              max: 60,
              divisions: 30,
              label: '${silenceThreshold.toInt()}dB',
              onChanged: (value) => setState(() => silenceThreshold = -value),
            ),
            _buildValueDisplay('${silenceThreshold.toInt()} dB'),

            const SizedBox(height: AppSpacing.sm),
            _buildTip(
              '💡 提示：值越小越严格，建议从默认值开始调整',
            ),

            const SizedBox(height: AppSpacing.xl),

            // 预设选项
            _buildPresetSection(),

            const SizedBox(height: AppSpacing.xl),

            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'silenceDuration': silenceDuration,
                      'silenceThreshold': silenceThreshold,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('应用设置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.0,
          color: AppColors.primary500,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary500,
        inactiveTrackColor: AppColors.primary100,
        thumbColor: AppColors.primary500,
        overlayColor: AppColors.primary500.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary500,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildValueDisplay(String value) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: AppColors.primary700,
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning500,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.warning500),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.0,
          color: AppColors.warning500,
        ),
      ),
    );
  }

  Widget _buildPresetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速预设',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildPresetChip(
              label: '默认',
              silenceDuration: 0.6,
              silenceThreshold: -40.0,
            ),
            _buildPresetChip(
              label: '宽松',
              silenceDuration: 0.8,
              silenceThreshold: -35.0,
            ),
            _buildPresetChip(
              label: '严格',
              silenceDuration: 0.4,
              silenceThreshold: -45.0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String label,
    required double silenceDuration,
    required double silenceThreshold,
  }) {
    final isSelected = this.silenceDuration == silenceDuration &&
        this.silenceThreshold == silenceThreshold;

    return InkWell(
      onTap: () {
        setState(() {
          this.silenceDuration = silenceDuration;
          this.silenceThreshold = silenceThreshold;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.neutral500,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
