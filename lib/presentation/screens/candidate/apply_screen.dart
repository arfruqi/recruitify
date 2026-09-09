import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/data/models/job.dart';
import 'package:recruitify/presentation/providers/application_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final Job job;
  const ApplyScreen({super.key, required this.job});

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  PlatformFile? pickedFile;
  bool isSubmitting = false;

  // Opens the device's file picker, restricted to PDFs. `withData: true`
  // makes it return the file's actual bytes directly (works the same on
  // mobile and web) instead of just a file path, which is what we need
  // to upload to Supabase Storage.
  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (pickedFile == null || pickedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume first')),
      );
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await ref.read(applicationProvider.notifier).submitApplication(
            jobId: widget.job.id,
            resumeBytes: pickedFile!.bytes!,
            fileName: pickedFile!.name,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Apply for Job'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.job.location, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Resume / CV', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickResume,
              icon: const Icon(Icons.upload_file),
              label: Text(pickedFile == null ? 'Choose PDF Resume' : pickedFile!.name),
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSubmitting ? null : _submitApplication,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
