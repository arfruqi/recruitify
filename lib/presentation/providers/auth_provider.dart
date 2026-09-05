import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Streams auth state changes (login/logout events) - AuthGate listens to this
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class AuthNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    // The 'data' here becomes raw_user_meta_data in Supabase's auth.users table.
    // A database trigger (handle_new_user) reads this and automatically
    // creates the matching profiles row - no manual insert needed here.
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role,
        'full_name': fullName,
        'phone': phone,
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authNotifierProvider = Provider<AuthNotifier>((ref) => AuthNotifier());