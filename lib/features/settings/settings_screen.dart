import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/app_localizations.dart';
import '../../state/app_settings_providers.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final notificationEnabled = ref.watch(notificationToggleProvider);
    final reminderTime = ref.watch(reminderTimeProvider);
    final notifications = ref.watch(notificationsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.t('settings.title') ?? 'Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n?.t('settings.language') ?? 'Language'),
            subtitle: Text(locale.languageCode == 'tr' ? 'Türkçe' : 'English'),
            trailing: DropdownButton<Locale>(
              value: locale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appLocaleProvider.notifier).setLocale(value);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('tr'), child: Text('Türkçe')),
              ],
            ),
          ),
          SwitchListTile(
            value: notificationEnabled,
            onChanged: (value) {
              ref.read(notificationToggleProvider.notifier).state = value;
              ref
                  .read(sharedPreferencesProvider)
                  .setBool('notifications_enabled', value);
              notifications.scheduleDailyReminder(
                time: reminderTime,
                enabled: value,
                body: l10n?.t('settings.reminder_body') ??
                    'Check in with yourself – today is still open.',
              );
            },
            title: Text(l10n?.t('settings.notifications') ?? 'Daily reminder'),
          ),
          ListTile(
            title: const Text('Reminder time'),
            subtitle: Text(reminderTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: reminderTime,
              );
              if (time != null) {
                ref.read(reminderTimeProvider.notifier).state = time;
                final prefs = ref.read(sharedPreferencesProvider);
                prefs
                  ..setInt('reminder_hour', time.hour)
                  ..setInt('reminder_minute', time.minute);
                notifications.scheduleDailyReminder(
                  time: time,
                  enabled: notificationEnabled,
                  body: l10n?.t('settings.reminder_body') ??
                      'Check in with yourself – today is still open.',
                );
              }
            },
          ),
          ListTile(
            title: Text(l10n?.t('settings.identity') ?? 'Identity & Values'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
