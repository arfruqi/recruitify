import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/application.dart';

class ApplicationNotifier extends AsyncNotifier<List<Application>> {
  @override
  Future<List<Application>> build() async {
    return await fetchMyApplications();
  }

  Future<List<Application>> fetchMyApplications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    // 'jobs(title, location)' is an EMBEDDED JOIN - Supabase follows the
    // foreign key (applications.job_id -> jobs.id) automatically and
    // nests the requested job columns inside each application's result.
    // One query instead of fetching applications, then separately
    // fetching each related job.
    final response = await Supabase.instance.client
        .from('applications')
        .select('*, jobs(title, location)')
        .eq('candidate_id', user.id)
        .order('applied_at', ascending: false);

    return response.map((item) => Application.fromJson(item)).toList();
  }

  // Uploads the resume file to Storage, then creates the application row
  // pointing at where that file now lives.
  Future<void> submitApplication({
    required String jobId,
    required List<int> resumeBytes,
    required String fileName,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // Prevent applying twice to the same job.
    final existing = await Supabase.instance.client
        .from('applications')
        .select()
        .eq('job_id', jobId)
        .eq('candidate_id', user.id)
        .maybeSingle();

    if (existing != null) {
      throw Exception('You have already applied to this job');
    }

    // File path pattern: <candidateId>/<filename> - this matters because
    // the Storage RLS policy checks that the first folder in the path
    // matches the uploader's own user ID.
    final storagePath = '${user.id}/$fileName';

    await Supabase.instance.client.storage.from('resumes').uploadBinary(
          storagePath,
          Uint8List.fromList(resumeBytes),
          fileOptions: const FileOptions(upsert: true),
        );

    await Supabase.instance.client.from('applications').insert({
      'job_id': jobId,
      'candidate_id': user.id,
      'resume_url': storagePath, // stores the PATH, not a public URL - bucket is private
      'status': 'applied',
    });

    state = AsyncValue.data(await fetchMyApplications());
  }
}

final applicationProvider =
    AsyncNotifierProvider<ApplicationNotifier, List<Application>>(ApplicationNotifier.new);