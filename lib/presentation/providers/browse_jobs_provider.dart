import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/job.dart';

// Unlike JobNotifier (recruiter's own jobs), this fetches ALL open jobs,
// from every recruiter - no .eq('recruiter_id', ...) filter. This is what
// makes it "browse jobs" instead of "my jobs".
final browseJobsProvider = FutureProvider<List<Job>>((ref) async {
  final response = await Supabase.instance.client
      .from('jobs')
      .select()
      .eq('status', 'open')
      .order('created_at', ascending: false);

  return response.map((item) => Job.fromJson(item)).toList();
});
