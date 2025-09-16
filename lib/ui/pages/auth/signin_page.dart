import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/helpers/url_launcher.dart';
import 'package:oratio_app/ui/pages/auth/auth_wrapper.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  bool isValid(BuildContext context) {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError(context, message: 'Email and Password are required');
      return false;
    }
    return true;
  }

  // TODO check if user has already logged in on device and suggest email so that user just needs his password
  // TODO ALSO ALLOW USER TO TURN OF THIS FEATURE FROM SETTINGS
  

  Future<void> _handleLogin(BuildContext context) async {
    if (isValid(context)) {
      try {
        final pb = context.read<PocketBaseServiceCubit>().state.pb;
        final auth = await pb.collection('users').authWithPassword(
            emailController.text.trim(), passwordController.text.trim());
      } on ClientException catch (e) {
        if (e.statusCode == 400) {
          showError(context, message: 'Invalid email or password');
          return;
        }
        showError(context, message: 'Client connection error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthListener(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: [
                const Gap(40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                            image: AssetImage('assets/images/app_logo.png'),
                            fit: BoxFit.cover),
                      ),
                      // child: Icon(
                      //   Icons.church_outlined,
                      //   size: 48,
                      //   color: AppColors.primary,
                      // ),
                    ),
                    const Gap(24),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'Continue Your Spiritual Journey',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Gap(48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFieldd(
                        labeltext: 'Email Address',
                        hintText: 'e.g johndoe@gmail.com',
                        controller: emailController,
                        isPassword: false,
                        inputType: TextInputType.emailAddress,
                      ),
                      const Gap(20),
                      TextFieldd(
                        labeltext: 'Password',
                        hintText: 'must contain 8 or more characters',
                        controller: passwordController,
                        isPassword: true,
                      ),
                      const Gap(16),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteNames.forgotpwpage);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: AppColors.primary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Gap(24),
                      StatefulBuilder(
                        builder: (context, rebuild) {
                          return ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    rebuild(() => _isLoading = true);
                                    await _handleLogin(context);
                                    rebuild(() => _isLoading = false);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              _isLoading ? 'Please wait...' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.goNamed(RouteNames.signup);
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    )
                  ],
                ),
                const Gap(32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        openTermsUrl(context);
                      },
                      child: Text(
                        "Terms of Use",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "•",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => openPolicyUrl(context),
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
