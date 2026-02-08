import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';

/// Energy levels for the selector.
enum EnergyLevel { low, medium, high }

/// Energy selector with three text-only pill buttons.
///
/// Calm Operational UI: No icons, no emojis.
/// - Selected: accentSoft background, accentPrimary text
/// - Unselected: transparent background, textSecondary
/// - Motion: 200ms easeInOut (subtle, non-bouncy)
class EnergySelector extends StatelessWidget {
  const EnergySelector({
    required this.selectedLevel,
    required this.onLevelSelected,
    super.key,
  });

  final EnergyLevel selectedLevel;
  final ValueChanged<EnergyLevel> onLevelSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          "How's your energy?",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: _EnergyPill(
              label: 'Low',
              isSelected: selectedLevel == EnergyLevel.low,
              onTap: () => onLevelSelected(EnergyLevel.low),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EnergyPill(
              label: 'Medium',
              isSelected: selectedLevel == EnergyLevel.medium,
              onTap: () => onLevelSelected(EnergyLevel.medium),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EnergyPill(
              label: 'High',
              isSelected: selectedLevel == EnergyLevel.high,
              onTap: () => onLevelSelected(EnergyLevel.high),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Text-only pill button for energy selection.
class _EnergyPill extends StatelessWidget {
  const _EnergyPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.durationShort,
        curve: AppMotion.curveStandard,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary.withAlpha(80)
                : AppColors.divider,
          ),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.durationShort,
            curve: AppMotion.curveStandard,
            style: theme.textTheme.labelLarge!.copyWith(
              color: isSelected
                  ? AppColors.accentPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
