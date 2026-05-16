import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'ask_expert_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const AskExpertScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context).currentLanguage;
    final t = translations[lang]!;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t['home'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: t['history'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology),
            label: t['ask_expert'],
          ),
        ],
      ),
    );
  }
}
