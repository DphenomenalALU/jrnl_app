import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/jrnl_bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const JrnlApp());
}

class JrnlApp extends StatelessWidget {
  const JrnlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JRNL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Bumps when opening Journal from Home so [JournalScreen] remounts with fresh state.
  int _journalSession = 0;

  void _openJournalFromHome() {
    setState(() {
      _index = 1;
      _journalSession++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        sizing: StackFit.expand,
        children: [
          HomeScreen(onStartJournaling: _openJournalFromHome),
          JournalScreen(
            key: ValueKey<int>(_journalSession),
            onPostEntryComplete: () => setState(() => _index = 2),
          ),
          const LeaderboardScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: JrnlBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
