import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/data/models/candidate_profile.dart';
import 'package:recruitify/presentation/providers/candidate_profile_provider.dart';
import 'package:recruitify/presentation/providers/auth_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class CandidateProfileScreen extends ConsumerWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(candidateProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider).signOut(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: profileAsync.when(
        // profile can be null (first time, no row saved yet) - form still renders, just empty
        data: (profile) => _ProfileForm(initialProfile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// Separate StatefulWidget so we can pre-fill controllers ONCE from the loaded
// data (in initState), same pattern as TaskEditScreen receiving `task`.
class _ProfileForm extends ConsumerStatefulWidget {
  final CandidateProfile? initialProfile;
  const _ProfileForm({required this.initialProfile});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late TextEditingController educationController;
  late TextEditingController fieldController;
  late TextEditingController preferencesController;
  late TextEditingController skillsController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    educationController = TextEditingController(text: widget.initialProfile?.education ?? '');
    fieldController = TextEditingController(text: widget.initialProfile?.fieldOfInterest ?? '');
    preferencesController = TextEditingController(text: widget.initialProfile?.jobPreferences ?? '');
    skillsController = TextEditingController(text: widget.initialProfile?.skills.join(', ') ?? '');
  }

  @override
  void dispose() {
    educationController.dispose();
    fieldController.dispose();
    preferencesController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);
    try {
      final skillsList = skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await ref.read(candidateProfileProvider.notifier).saveCandidateProfile(
            education: educationController.text.trim(),
            fieldOfInterest: fieldController.text.trim(),
            jobPreferences: preferencesController.text.trim(),
            skills: skillsList,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: educationController, decoration: _decoration('Education')),
          const SizedBox(height: 12),
          TextField(controller: fieldController, decoration: _decoration('Field of Interest')),
          const SizedBox(height: 12),
          TextField(
            controller: preferencesController,
            decoration: _decoration('Job Preferences'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: skillsController,
            decoration: _decoration('Skills (comma-separated, e.g. Flutter, Dart, Firebase)'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSaving ? null : _handleSave,
              child: isSaving
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}