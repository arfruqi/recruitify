import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/auth_provider.dart';
import 'package:recruitify/presentation/screens/recruiter/recruiter_profile_screen.dart';
import 'package:recruitify/presentation/screens/recruiter/my_jobs_screen.dart';

class RecruiterHomeScreen extends ConsumerWidget {
  const RecruiterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recruiter Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecruiterProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyJobsScreen()),
            );
          },
          child: const Text('View My Job Postings'),
        ),
      ),
    );
  }
}