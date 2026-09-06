import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/job.dart';

class JobNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    return await fetchMyJobs();
  }

  // Only fetches jobs posted by the CURRENTLY LOGGED IN recruiter, not all jobs.
  // (Candidates browsing all jobs will use a separate provider later - that
  // one won't filter by recruiter_id, since candidates need to see everyone's jobs.)
  Future<List<Job>> fetchMyJobs() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final response = await Supabase.instance.client
        .from('jobs')
        .select()
        .eq('recruiter_id', user.id)
        .order('created_at', ascending: false);

    return response.map((item) => Job.fromJson(item)).toList();
  }

  Future<void> addJob({
    required String title,
    required String description,
    required String requirements,
    required String location,
    required String salaryRange,
    required String jobType,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await Supabase.instance.client.from('jobs').insert({
      'recruiter_id': user.id,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'salary_range': salaryRange,
      'job_type': jobType,
      'status': 'open',
    });

    state = AsyncValue.data(await fetchMyJobs());
  }

  Future<void> updateJob(Job job) async {
    await Supabase.instance.client.from('jobs').update({
      'title': job.title,
      'description': job.description,
      'requirements': job.requirements,
      'location': job.location,
      'salary_range': job.salaryRange,
      'job_type': job.jobType,
      'status': job.status,
    }).eq('id', job.id);

    state = AsyncValue.data(await fetchMyJobs());
  }

  Future<void> deleteJob(String jobId) async {
    await Supabase.instance.client.from('jobs').delete().eq('id', jobId);
    state = AsyncValue.data(await fetchMyJobs());
  }
}

final jobProvider = AsyncNotifierProvider<JobNotifier, List<Job>>(JobNotifier.new);
