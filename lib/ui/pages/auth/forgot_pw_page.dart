import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:glass/glass.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  String? email;

  Future generateToken(BuildContext context) async {
    if (emailController.text.isEmpty) {
      NotificationService.showError('Enter a valid email first');
      return;
    } else {
      setState(() {
        email = emailController.text.trim();
      });
    }
    try {
      await context
          .read<PocketBaseServiceCubit>()
          .state
          .pb
          .collection('users')
          .requestPasswordReset(emailController.text.trim());
    } catch (e) {
      NotificationService.showError('Invalid Email, account doesn\'t exist');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF9333EA), // Purple
              Color(0xFFDB2777), // Pink
            ],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: email == null
                ? SendEmailScreen(
                    controller: emailController,
                    isLoading: _isLoading,
                    onSubmit: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await generateToken(context);
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  )
                : ChangePasswordScreen(
                    email: emailController.text.trim(),
                    onBackToEmail: () {
                      setState(() {
                        email = null;
                      });
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class SendEmailScreen extends StatelessWidget {
  const SendEmailScreen({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Gap(30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    'Let\'s help you recover your account',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Gap(20),
                  Text(
                    'You will receive a recovery token in your email\nNote: if email isn\'t found, check your spam folder',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Gap(40),
            TextFieldd(
              labeltext: 'Email',
              hintText: 'Enter your email here',
              controller: controller,
              isPassword: false,
              inputType: TextInputType.emailAddress,
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: Text(
                isLoading ? 'Please wait...' : 'Get Recovery Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLoading
                      ? const Color(0xFF6366F1).withOpacity(0.6)
                      : const Color(0xFF6366F1),
                ),
              ),
            ),
            const Gap(20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final VoidCallback onBackToEmail;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.onBackToEmail,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  int _countdown = 60;
  bool _canResend = false;
  bool _isResending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _countdown = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          if (_countdown == 0) {
            setState(() {
              _canResend = true;
              timer.cancel();
            });
          } else {
            setState(() {
              _countdown--;
            });
          }
        }
      },
    );
  }

  Future<void> resendEmail() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      await context
          .read<PocketBaseServiceCubit>()
          .state
          .pb
          .collection('users')
          .requestPasswordReset(widget.email);

      if (mounted) {
        startTimer();
        NotificationService.showSuccess('Recovery email sent');
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError('Failed to send recovery email');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                FontAwesomeIcons.envelopeCircleCheck,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const Gap(32),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Check your email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(16),
                  const Text(
                    'We have sent instructions to:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton.icon(
                    onPressed: _canResend && !_isResending ? resendEmail : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      _isResending
                          ? FontAwesomeIcons.spinner
                          : _canResend
                              ? FontAwesomeIcons.paperPlane
                              : FontAwesomeIcons.clock,
                      size: 16,
                    ),
                    label: Text(
                      _isResending
                          ? 'Sending...'
                          : _canResend
                              ? 'Resend Email'
                              : '$_countdown seconds',
                      style: TextStyle(
                        color: _isResending || !_canResend
                            ? const Color.fromARGB(255, 233, 233, 233)
                                .withOpacity(0.6)
                            : const Color.fromARGB(255, 232, 232, 232),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: widget.onBackToEmail,
                        child: const Text(
                          'Change Email',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
