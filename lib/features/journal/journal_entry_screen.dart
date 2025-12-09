import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journal_entry.dart';
import '../../state/journal_providers.dart';
import '../../state/profile_providers.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, this.entry});

  final JournalEntry? entry;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entry?.title ?? '');
    contentController =
        TextEditingController(text: widget.entry?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                expands: true,
                maxLines: null,
                minLines: null,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _save(context),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final repo = ref.read(journalRepositoryProvider);
    final profile = await ref.read(profileProvider.future);

    if (widget.entry == null) {
      await repo.createEntry(
        userId: profile.id,
        title: titleController.text,
        content: contentController.text,
      );
    } else {
      await repo.updateEntry(
        widget.entry!.copyWith(
          title: titleController.text,
          content: contentController.text,
        ),
      );
    }

    ref.invalidate(journalEntriesProvider);
    if (context.mounted) Navigator.of(context).pop();
  }
}
