import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/data/models/recruiter_profile.dart';
import 'package:recruitify/presentation/providers/recruiter_profile_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class RecruiterProfileScreen extends ConsumerWidget {
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(recruiterProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: profileAsync.when(
        data: (profile) => _ProfileForm(initialProfile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  final RecruiterProfile? initialProfile;
  const _ProfileForm({required this.initialProfile});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late TextEditingController businessNameController;
  late TextEditingController locationController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    businessNameController = TextEditingController(text: widget.initialProfile?.businessName ?? '');
    locationController = TextEditingController(text: widget.initialProfile?.location ?? '');
  }

  @override
  void dispose() {
    businessNameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);
    try {
      await ref.read(recruiterProfileProvider.notifier).saveRecruiterProfile(
            businessName: businessNameController.text.trim(),
            location: locationController.text.trim(),
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
          TextField(controller: businessNameController, decoration: _decoration('Business Name')),
          const SizedBox(height: 12),
          TextField(controller: locationController, decoration: _decoration('Location')),
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
