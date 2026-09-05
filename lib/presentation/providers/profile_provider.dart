import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/profile.dart';
import 'package:recruitify/presentation/providers/auth_provider.dart';

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider); // re-fetch whenever auth state changes

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return null;
  return Profile.fromJson(response);
});
