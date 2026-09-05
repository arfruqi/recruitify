import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/auth_provider.dart';
import 'package:recruitify/presentation/providers/profile_provider.dart';
import 'package:recruitify/presentation/screens/auth/login_screen.dart';
import 'package:recruitify/presentation/screens/candidate/candidate_home_screen.dart';
import 'package:recruitify/presentation/screens/recruiter/recruiter_home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        final session = state.session;
        if (session == null) {
          return const LoginScreen();
        }

        final profileAsync = ref.watch(currentProfileProvider);
        return profileAsync.when(
          data: (profile) {
            if (profile == null) {
              // Session exists but no profile row found - fall back to login
              return const LoginScreen();
            }
            if (profile.role == 'candidate') {
              return const CandidateHomeScreen();
            } else {
              return const RecruiterHomeScreen();
            }
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
