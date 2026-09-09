import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/screens/recruiter/my_jobs_screen.dart';
import 'package:recruitify/presentation/screens/recruiter/recruiter_profile_screen.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class RecruiterHomeScreen extends ConsumerStatefulWidget {
  const RecruiterHomeScreen({super.key});

  @override
  ConsumerState<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends ConsumerState<RecruiterHomeScreen> {
  int currentIndex = 0;

  final screens = const [
    MyJobsScreen(),
    RecruiterProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: accentColor,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}