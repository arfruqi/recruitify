import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/screens/candidate/browse_jobs_screen.dart';
import 'package:recruitify/presentation/screens/candidate/my_applications_screen.dart';
import 'package:recruitify/presentation/screens/candidate/messages_screen.dart';
import 'package:recruitify/presentation/screens/candidate/candidate_profile_screen.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class CandidateHomeScreen extends ConsumerStatefulWidget {
  const CandidateHomeScreen({super.key});

  @override
  ConsumerState<CandidateHomeScreen> createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends ConsumerState<CandidateHomeScreen> {
  int currentIndex = 0;

  final screens = const [
    BrowseJobsScreen(),
    MyApplicationsScreen(),
    MessagesScreen(),
    CandidateProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: accentColor,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}