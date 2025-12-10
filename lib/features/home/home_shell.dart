import 'package:flutter/material.dart';

import '../checkin/checkin_screen.dart';
import '../habits/habits_screen.dart';
import '../journal/journal_screen.dart';
import '../learn/learn_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final tabs = const [
    HomeScreen(),
    HabitsScreen(),
    JournalScreen(),
    LearnScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.checklist_rounded), label: 'Habits'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.lightbulb_outline), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyCheckinScreen()),
              ),
              label: const Text('Check in'),
              icon: const Icon(Icons.bolt_outlined),
            )
          : null,
    );
  }
}
