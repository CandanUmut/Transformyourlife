import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile.dart';
import '../../localization/app_localizations.dart';
import '../../state/profile_providers.dart';
import '../../state/app_settings_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _primaryFocus;
  final Set<String> _paths = {};
  final identityController = TextEditingController();
  final valuesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.t('onboarding.title') ?? 'Shape your path')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(l10n?.t('onboarding.primary_focus') ?? 'Primary focus'),
              Wrap(
                spacing: 8,
                children: [
                  'break_habit',
                  'build_habits',
                  'find_direction',
                ].map((focus) {
                  return ChoiceChip(
                    label: Text(focus.replaceAll('_', ' ')),
                    selected: _primaryFocus == focus,
                    onSelected: (_) => setState(() => _primaryFocus = focus),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n?.t('onboarding.paths') ?? 'Paths'),
              Wrap(
                spacing: 8,
                children: ['Body', 'Mind', 'Heart', 'Spirit'].map((path) {
                  final isSelected = _paths.contains(path.toLowerCase());
                  return FilterChip(
                    label: Text(path),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _paths.add(path.toLowerCase());
                        } else {
                          _paths.remove(path.toLowerCase());
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: identityController,
                decoration: InputDecoration(
                  labelText: l10n?.t('onboarding.identity') ?? 'Identity statement',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: valuesController,
                decoration: InputDecoration(
                  labelText: l10n?.t('onboarding.values') ?? 'Values',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _primaryFocus == null ? null : () => _submit(context),
                child: Text(l10n?.t('onboarding.continue') ?? 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final profileRepo = ref.read(profileRepositoryProvider);
    final deviceId = ref.read(deviceIdProvider);

    final profile = Profile(
      id: deviceId,
      primaryFocus: _primaryFocus,
      paths: _paths.toList(),
      identityStatement: identityController.text,
      values: valuesController.text,
    );

    await profileRepo.updateProfile(profile);
    ref.invalidate(profileProvider);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
