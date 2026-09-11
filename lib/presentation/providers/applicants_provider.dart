import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/application.dart';
import 'package:recruitify/data/models/candidate_profile.dart';

// FAMILY PROVIDER: unlike every provider so far, this one needs a PARAMETER
// (which job's applicants to fetch) - a plain provider has no way to take
// input like that. '.family' lets you call it as
// applicantsForJobProvider(someJobId) from the UI, and Riverpod creates a
// separate cached instance per distinct jobId automatically.
final applicantsForJobProvider = FutureProvider.family<List<Application>, String>((ref, jobId) async {
  final response = await Supabase.instance.client
      .from('applications')
      .select('*, profiles(full_name, email)')
      .eq('job_id', jobId)
      .order('applied_at', ascending: false);

  return response.map((item) => Application.fromJson(item)).toList();
});

// Fetches full candidate profile details for the applicant detail screen -
// separate from the list above, since the list only needs name/email, but
// the detail view needs education/skills/etc too.
final candidateDetailProvider = FutureProvider.family<CandidateProfile?, String>((ref, candidateId) async {
  final response = await Supabase.instance.client
      .from('candidate_profiles')
      .select()
      .eq('id', candidateId)
      .maybeSingle();

  if (response == null) return null;
  return CandidateProfile.fromJson(response);
});

// Generates a temporary, time-limited URL to view a private resume file.
// The bucket is private, so there's no permanent public link - this is the
// correct way to grant short-term access to one specific file.
Future<String> getResumeSignedUrl(String resumePath) async {
  final response = await Supabase.instance.client.storage
      .from('resumes')
      .createSignedUrl(resumePath, 60 * 10); // valid for 10 minutes
  return response;
}
