import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/learn_cards.dart';
import '../../localization/app_localizations.dart';
import '../../state/badges_provider.dart';
import '../../state/checkins_providers.dart';
import '../../state/habits_providers.dart';
import '../../state/profile_providers.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/progress_bars.dart';
import '../../widgets/transform_card.dart';
import '../checkin/checkin_screen.dart';
import '../learn/learn_screen.dart';

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
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n?.t('home.greeting') ?? 'Welcome back'}, ${profile.primaryFocus?.split(' ').first ?? l10n?.t('home.friend') ?? 'friend'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if ((profile.identityStatement ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      profile.identityStatement!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                  ),
              ],
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
            loading: const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          completionAsync.when(
            data: (progress) => _HabitProgress(progress: progress),
            loading: const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          habitsAsync.when(
            data: (habits) => TransformCard(
              title: l10n?.t('home.today_habits') ?? "Today's habits",
              subtitle: l10n?.t('home.habits_encouragement') ??
                  'Tiny steps count. Choose one to honor today.',
              child: Column(
                children: habits.take(3).map(
                  (habit) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(habit.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              if (habit.path != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: PillChip(label: habit.path!),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),
            loading: const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          badgesAsync.when(
            data: (badges) => TransformCard(
              title: l10n?.t('home.badges') ?? 'Achievements',
              subtitle: l10n?.t('home.badges_copy') ??
                  'Each streak and honest check-in earns you a light.',
              child: Wrap(
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
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 12),
          _LearnTeaser(),
        ],
      ),
    );
  }

  Widget _buildCheckinCard(BuildContext context, AppLocalizations? l10n,
      AsyncValue checkinAsync) {
    return TransformCard(
      title: l10n?.t('home.checkin_prompt') ?? 'Did you check in?',
      subtitle: l10n?.t('home.checkin_subtitle') ??
          'A 30-second reflection keeps your streak alive.',
      child: checkinAsync.when(
        data: (checkin) {
          if (checkin == null) {
            return FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DailyCheckinScreen(),
                ),
              ),
              icon: const Icon(Icons.bolt),
              label: Text(l10n?.t('home.view_checkin') ?? 'Go to check-in'),
            );
          }
          final haltFlags = checkin.halt.entries
              .where((entry) => entry.value == true)
              .map((e) => e.key)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${l10n?.t('checkin.mood') ?? 'Mood'}: ${checkin.mood ?? '-'}'),
              const SizedBox(height: 6),
              Text(
                  '${l10n?.t('checkin.urge') ?? 'Urge level'}: ${checkin.urgeLevel ?? '-'}'),
              const SizedBox(height: 6),
              if (checkin.slip)
                Text(
                  l10n?.t('home.slip_copy') ??
                      'You logged a slip today. Thank you for being honest. Tomorrow is still open.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.orange.shade800),
                ),
              if (haltFlags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: haltFlags
                      .map((flag) => PillChip(label: flag))
                      .toList(),
                ),
              ],
            ],
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
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
    return TransformCard(
      title: 'Streak health',
      subtitle: 'Next milestone at 7 days',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current streak: $current days'),
          const SizedBox(height: 8),
          StreakBar(progress: (current % 7) / 7),
          const SizedBox(height: 12),
          Text('Best streak: $best days'),
        ],
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
    return TransformCard(
      title: "Today's habits: $percent%",
      subtitle: 'Gentle steps count. Today is still open.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodayProgressBar(progress: progress),
          const SizedBox(height: 8),
          Text('Completed ${percent}% of active habits'),
        ],
      ),
    );
  }
}

class _LearnTeaser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final options = [...learnCards]..shuffle();
    final card = options.first;
    return TransformCard(
      title: Localizations.of<AppLocalizations>(context, AppLocalizations)
              ?.t('learn.title') ??
          'Learn',
      subtitle:
          Localizations.of<AppLocalizations>(context, AppLocalizations)
                  ?.t('learn.tagline') ??
              'A 30-second insight to carry today',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _LearnDetail(card: card)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            card.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
