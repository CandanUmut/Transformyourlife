import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'localization/app_localizations.dart';
import 'state/app_settings_providers.dart';
import 'state/profile_providers.dart';

class TransformApp extends ConsumerWidget {
  const TransformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: 'Transform Your Life',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: buildAppTheme(GoogleFonts.interTextTheme()),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile.primaryFocus == null || profile.primaryFocus!.isEmpty) {
          return const OnboardingScreen();
        }
        return const HomeShell();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load profile: $error'),
          ),
        ),
      ),
    );
  }
}
