import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/candidate_profile.dart';

class CandidateProfileNotifier extends AsyncNotifier<CandidateProfile?> {
  @override
  Future<CandidateProfile?> build() async {
    return await fetchCandidateProfile();
  }

  Future<CandidateProfile?> fetchCandidateProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('candidate_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return CandidateProfile.fromJson(response);
  }

  Future<void> saveCandidateProfile({
    required String education,
    required String fieldOfInterest,
    required String jobPreferences,
    required List<String> skills,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // upsert = insert if no row exists yet, update if it does - one call handles both.
    await Supabase.instance.client.from('candidate_profiles').upsert({
      'id': user.id,
      'education': education,
      'field_of_interest': fieldOfInterest,
      'job_preferences': jobPreferences,
      'skills': skills,
    });

    state = AsyncValue.data(await fetchCandidateProfile());
  }
}

final candidateProfileProvider =
    AsyncNotifierProvider<CandidateProfileNotifier, CandidateProfile?>(CandidateProfileNotifier.new);
