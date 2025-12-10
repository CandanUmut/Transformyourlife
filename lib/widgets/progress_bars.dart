import 'package:flutter/material.dart';

class StreakBar extends StatelessWidget {
  const StreakBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: 10,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      ),
    );
  }
}

class TodayProgressBar extends StatelessWidget {
  const TodayProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: 14,
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
