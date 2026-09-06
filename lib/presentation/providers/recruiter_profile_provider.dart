import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/recruiter_profile.dart';

class RecruiterProfileNotifier extends AsyncNotifier<RecruiterProfile?> {
  @override
  Future<RecruiterProfile?> build() async {
    return await fetchRecruiterProfile();
  }

  Future<RecruiterProfile?> fetchRecruiterProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('recruiter_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return RecruiterProfile.fromJson(response);
  }

  Future<void> saveRecruiterProfile({
    required String businessName,
    required String location,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await Supabase.instance.client.from('recruiter_profiles').upsert({
      'id': user.id,
      'business_name': businessName,
      'location': location,
    });

    state = AsyncValue.data(await fetchRecruiterProfile());
  }
}

final recruiterProfileProvider =
    AsyncNotifierProvider<RecruiterProfileNotifier, RecruiterProfile?>(RecruiterProfileNotifier.new);
