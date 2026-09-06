import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/presentation/providers/auth_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const VerifyEmailScreen({super.key, required this.email, required this.password});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool isChecking = false;
  String? statusMessage;

  // Retries login using the default Supabase confirmation link flow.
  // The link confirms the email on Supabase's server the moment it's
  // clicked - the redirect page afterward may look broken, but that
  // doesn't undo the confirmation. So retrying login here is enough to
  // detect success, without needing any custom email template or SMTP.
  Future<void> _checkVerificationStatus() async {
    setState(() {
      isChecking = true;
      statusMessage = null;
    });
    try {
      await ref.read(authNotifierProvider).signIn(
            email: widget.email,
            password: widget.password,
          );
      // Login succeeded, meaning the email IS confirmed. AuthGate (at the
      // root) has already switched to showing the correct home screen
      // internally - but this screen was PUSHED on top of it, so it's
      // still hiding that change. Popping back to the first route makes
      // the update actually visible.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Not verified yet. Check your inbox, click the link, then try again.';
      });
    } finally {
      if (mounted) {
        setState(() => isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not resend: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread, size: 72, color: accentColor),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "We've sent a verification link to:\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Click the link (you can ignore any error page that appears '
                'afterward), then come back and tap the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              if (statusMessage != null) ...[
                const SizedBox(height: 16),
                Text(statusMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.orange)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isChecking ? null : _checkVerificationStatus,
                  child: isChecking
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Check Verification Status'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _resendEmail,
                child: const Text('Resend Verification Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}