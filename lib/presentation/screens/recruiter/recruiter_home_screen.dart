import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/auth_provider.dart';

class RecruiterHomeScreen extends ConsumerWidget {
  const RecruiterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recruiter Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider).signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Recruiter home - placeholder, built next')),
    );
  }
}
