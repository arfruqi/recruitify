import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/data/models/job.dart';
import 'package:recruitify/presentation/providers/job_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

// Used for BOTH creating a new job (existingJob == null) and editing one
// (existingJob != null) - same pattern as your Task Tracker's edit screen,
// just handling two cases with one screen instead of two separate screens.
class PostJobScreen extends ConsumerStatefulWidget {
  final Job? existingJob;
  const PostJobScreen({super.key, this.existingJob});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController requirementsController;
  late TextEditingController locationController;
  late TextEditingController salaryController;
  String selectedJobType = 'Full-time';
  bool isSaving = false;

  final jobTypes = ['Full-time', 'Part-time', 'Remote', 'Contract'];

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    titleController = TextEditingController(text: job?.title ?? '');
    descriptionController = TextEditingController(text: job?.description ?? '');
    requirementsController = TextEditingController(text: job?.requirements ?? '');
    locationController = TextEditingController(text: job?.location ?? '');
    salaryController = TextEditingController(text: job?.salaryRange ?? '');
    if (job != null && jobTypes.contains(job.jobType)) {
      selectedJobType = job.jobType;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    locationController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);
    try {
      if (widget.existingJob == null) {
        // Creating a new job
        await ref.read(jobProvider.notifier).addJob(
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              requirements: requirementsController.text.trim(),
              location: locationController.text.trim(),
              salaryRange: salaryController.text.trim(),
              jobType: selectedJobType,
            );
      } else {
        // Editing an existing job - build an updated Job object, keeping
        // id/recruiterId/status the same, changing the rest
        final updatedJob = Job(
          id: widget.existingJob!.id,
          recruiterId: widget.existingJob!.recruiterId,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          requirements: requirementsController.text.trim(),
          location: locationController.text.trim(),
          salaryRange: salaryController.text.trim(),
          jobType: selectedJobType,
          status: widget.existingJob!.status,
        );
        await ref.read(jobProvider.notifier).updateJob(updatedJob);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving job: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
    final isEditing = widget.existingJob != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Job' : 'Post a Job'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: titleController, decoration: _decoration('Job Title')),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: _decoration('Job Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: requirementsController,
              decoration: _decoration('Requirements'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(controller: locationController, decoration: _decoration('Location')),
            const SizedBox(height: 12),
            TextField(controller: salaryController, decoration: _decoration('Salary Range (e.g. 50000-70000)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedJobType,
              decoration: _decoration('Job Type'),
              items: jobTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedJobType = value ?? selectedJobType);
              },
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
                    : Text(isEditing ? 'Save Changes' : 'Post Job'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
