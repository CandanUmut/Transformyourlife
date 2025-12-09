import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/habit.dart';
import '../../state/habits_providers.dart';
import '../../state/profile_providers.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: habitsAsync.when(
        data: (habits) => _HabitList(habits: habits),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddHabitDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    String path = 'body';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            DropdownButton<String>(
              value: path,
              items: const [
                DropdownMenuItem(value: 'body', child: Text('Body')),
                DropdownMenuItem(value: 'mind', child: Text('Mind')),
                DropdownMenuItem(value: 'heart', child: Text('Heart')),
              ],
              onChanged: (value) {
                if (value != null) {
                  path = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final profile = await ref.read(profileProvider.future);
              await ref
                  .read(habitsRepositoryProvider)
                  .createHabit(userId: profile.id, name: nameController.text, path: path);
              ref.invalidate(habitsProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  const _HabitList({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Habit>>{};
    for (final habit in habits) {
      final key = habit.path ?? 'other';
      grouped.putIfAbsent(key, () => []).add(habit);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Card(
          child: ExpansionTile(
            title: Text(entry.key.toUpperCase()),
            children: entry.value
                .map(
                  (habit) => ListTile(
                    title: Text(habit.name),
                    subtitle: Text(habit.path ?? ''),
                    trailing: habit.isActive
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.archive),
                  ),
                )
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}
