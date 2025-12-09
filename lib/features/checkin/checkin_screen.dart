import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/daily_checkin.dart';
import '../../state/badges_provider.dart';
import '../../state/checkins_providers.dart';
import '../../state/habits_providers.dart';
import '../../state/profile_providers.dart';

class DailyCheckinScreen extends ConsumerStatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  ConsumerState<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends ConsumerState<DailyCheckinScreen> {
  double _mood = 5;
  String _urge = 'none';
  bool _slip = false;
  final Map<String, bool> _halt = {
    'hungry': false,
    'angry': false,
    'lonely': false,
    'tired': false,
  };
  final Map<String, bool> _lifestyle = {
    'sleep_ok': false,
    'moved_body': false,
  };
  final notesController = TextEditingController();
  final Set<int> _completedHabits = {};

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final existingCheckinAsync = ref.watch(todayCheckinProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily check-in')),
      body: existingCheckinAsync.when(
        data: (existing) {
          if (existing != null) {
            _mood = (existing.mood ?? 5).toDouble();
            _urge = existing.urgeLevel ?? 'none';
            _slip = existing.slip;
            notesController.text = existing.notes ?? '';
            _completedHabits.addAll(existing.completedHabitIds);
            existing.halt.forEach((key, value) {
              _halt[key] = value == true;
            });
            existing.lifestyle.forEach((key, value) {
              _lifestyle[key] = value == true;
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Mood: ${_mood.round()}'),
              Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value: _mood,
                onChanged: (value) => setState(() => _mood = value),
              ),
              const SizedBox(height: 12),
              Text('Urge level'),
              Wrap(
                spacing: 8,
                children: ['none', 'mild', 'moderate', 'strong'].map((level) {
                  return ChoiceChip(
                    label: Text(level),
                    selected: _urge == level,
                    onSelected: (_) => setState(() => _urge = level),
                  );
                }).toList(),
              ),
              SwitchListTile(
                value: _slip,
                onChanged: (value) => setState(() => _slip = value),
                title: const Text('Slip'),
              ),
              const SizedBox(height: 12),
              Text('HALT'),
              Wrap(
                spacing: 8,
                children: _halt.entries.map((entry) {
                  return FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: (selected) => setState(() {
                      _halt[entry.key] = selected;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text('Lifestyle'),
              Wrap(
                spacing: 8,
                children: _lifestyle.entries.map((entry) {
                  return FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: (selected) => setState(() {
                      _lifestyle[entry.key] = selected;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              habitsAsync.when(
                data: (habits) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Habits today'),
                    ...habits.map(
                      (habit) => CheckboxListTile(
                        value: _completedHabits.contains(habit.id),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _completedHabits.add(habit.id);
                          } else {
                            _completedHabits.remove(habit.id);
                          }
                        }),
                        title: Text(habit.name),
                        subtitle: Text(habit.path ?? ''),
                      ),
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _save(context),
                child: const Text('Save check-in'),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final repo = ref.read(dailyCheckinsRepositoryProvider);
    final profile = await ref.read(profileProvider.future);
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    final checkin = DailyCheckin(
      userId: profile.id,
      date: date,
      mood: _mood.toInt(),
      urgeLevel: _urge,
      slip: _slip,
      notes: notesController.text,
      halt: _halt,
      lifestyle: _lifestyle,
      completedHabitIds: _completedHabits.toList(),
    );

    await repo.upsertCheckin(checkin);
    ref.invalidate(profileBadgesProvider);
    HapticFeedback.mediumImpact();
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in saved')),
      );
    }
  }
}
