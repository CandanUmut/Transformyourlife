import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/app_localizations.dart';
import '../../state/badges_provider.dart';
import '../../state/checkins_providers.dart';
import '../../state/habits_providers.dart';
import '../../state/profile_providers.dart';
import '../checkin/checkin_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final profileAsync = ref.watch(profileProvider);
    final streaksAsync = ref.watch(streaksProvider);
    final completionAsync = ref.watch(todayHabitCompletionProvider);
    final badgesAsync = ref.watch(profileBadgesProvider);
    final checkinAsync = ref.watch(todayCheckinProvider);
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.t('home.title') ?? 'Transform'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            data: (profile) => Text(
              '${l10n?.t('home.greeting') ?? 'Welcome back'},\n${profile.identityStatement ?? ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),
          _buildCheckinCard(context, l10n, checkinAsync),
          const SizedBox(height: 12),
          streaksAsync.when(
            data: (streaks) => _StreakCard(
              current: streaks['current'] ?? 0,
              best: streaks['best'] ?? 0,
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
            ),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          completionAsync.when(
            data: (progress) => _HabitProgress(progress: progress),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          habitsAsync.when(
            data: (habits) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n?.t('habits.title') ?? 'Habits',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...habits.take(3).map(
                  (habit) => Card(
                    child: ListTile(
                      title: Text(habit.name),
                      subtitle: Text(habit.path ?? ''),
                    ),
                  ),
                ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          badgesAsync.when(
            data: (badges) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map(
                    (id) => Chip(
                      avatar: const Icon(Icons.emoji_events, size: 18),
                      label: Text(id),
                    ),
                  )
                  .toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinCard(BuildContext context, AppLocalizations? l10n,
      AsyncValue checkinAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: checkinAsync.when(
          data: (checkin) {
            if (checkin == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n?.t('home.checkin_prompt') ?? 'Did you check in?'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DailyCheckinScreen(),
                      ),
                    ),
                    child: Text(l10n?.t('home.view_checkin') ?? 'Go to check-in'),
                  )
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood: ${checkin.mood ?? '-'}'),
                Text('Urge: ${checkin.urgeLevel ?? '-'}'),
                Text('Slip: ${checkin.slip ? 'Yes' : 'No'}'),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.current, required this.best});

  final int current;
  final int best;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current streak: $current days'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (current % 7) / 7),
            const SizedBox(height: 12),
            Text('Best streak: $best days'),
          ],
        ),
      ),
    );
  }
}

class _HabitProgress extends StatelessWidget {
  const _HabitProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's habits: $percent%"),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0, 1)),
          ],
        ),
      ),
    );
  }
}
