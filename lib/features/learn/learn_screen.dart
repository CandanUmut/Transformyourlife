import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/learn_cards.dart';
import '../../data/models/learn_card.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/transform_card.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final categories = {
      'all',
      ...learnCards.map((c) => c.category)
    }.toList();
    final filtered = selectedCategory == null || selectedCategory == 'all'
        ? learnCards
        : learnCards.where((c) => c.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.t('learn.title') ?? 'Learn'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: l10n?.t('learn.tagline') ?? 'Tiny lessons you can use today',
            subtitle:
                l10n?.t('learn.subtitle') ?? 'Short reads on habits and identity.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (c) => ChoiceChip(
                    label: Text(c == 'all' ? (l10n?.t('learn.all') ?? 'All') : c),
                    selected: selectedCategory == c ||
                        (selectedCategory == null && c == 'all'),
                    onSelected: (_) => setState(() {
                      selectedCategory = c == 'all' ? null : c;
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            EmptyState(
              message:
                  l10n?.t('learn.empty') ?? 'No lessons found for this category yet.',
            )
          else
            ...filtered.map((card) => _LearnCardTile(card: card)).toList(),
        ],
      ),
    );
  }
}

class _LearnCardTile extends StatelessWidget {
  const _LearnCardTile({required this.card});

  final LearnCard card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TransformCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LearnDetail(card: card)),
        ),
        title: card.title,
        subtitle: card.category,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (card.tryThis != null) ...[
              const SizedBox(height: 8),
              Text(
                card.tryThis!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class LearnDetail extends StatelessWidget {
  const LearnDetail({super.key, required this.card});

  final LearnCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return Scaffold(
      appBar: AppBar(title: Text(card.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.category.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            Text(card.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.body, style: Theme.of(context).textTheme.bodyLarge),
                    if (card.tryThis != null) ...[
                      const SizedBox(height: 16),
                      Text(l10n?.t('learn.try_today') ?? 'Try today',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(card.tryThis!),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
