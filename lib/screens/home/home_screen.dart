import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediminder/providers/medicine_provider.dart';
import 'package:mediminder/screens/home/dashboard_tab.dart';
import 'package:mediminder/screens/home/reminders_tab.dart';
import 'package:mediminder/screens/home/history_tab.dart';
import 'package:mediminder/screens/home/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _tabs = const [
    DashboardTab(),
    RemindersTab(),
    HistoryTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().initializeData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _tabs,
        onPageChanged: (index) => setState(() => _currentIndex = index),
      ),

      /// Bottom Navigation with slide effect
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            final icons = [
              Icons.dashboard_outlined,
              Icons.medication_outlined,
              Icons.history_outlined,
              Icons.person_outline,
            ];
            final activeIcons = [
              Icons.dashboard,
              Icons.medication,
              Icons.history,
              Icons.person,
            ];
            final labels = ["Dashboard", "Reminders", "History", "Profile"];
            final isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? activeIcons[index] : icons[index],
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    child: Text(labels[index]),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
