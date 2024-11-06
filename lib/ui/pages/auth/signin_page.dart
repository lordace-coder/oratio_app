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

  Future<void> _handleLogin(BuildContext context) async {
    if (isValid(context)) {
      // submit form data
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
        backgroundColor: AppColors.primary,
        body: SafeArea(
            child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            children: [
              const Gap(30),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'WELCOME BACK!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold),
                  ),
                  Gap(20),
                  Text('Get Closer With God Today',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('TODAY',
                      style: TextStyle(color: Colors.white, fontSize: 18))
                ],
              ),
              const Gap(40),
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
              const Gap(10),
              GestureDetector(
                onTap: () {
                  context.pushNamed(RouteNames.forgotpwpage);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'forgot password?',
                      style: TextStyle(color: Colors.white.withOpacity(.5)),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.goNamed(RouteNames.signup);
                    },
                    child: Text(
                      ' sign up!',
                      style: TextStyle(color: AppColors.green),
                    ),
                  )
                ],
              ),
              const Gap(20),
              StatefulBuilder(builder: (context, rebuild) {
                return SubmitButtonV1(
                    ontap: () async {
                      if (_isLoading) return;
                      rebuild(() {
                        _isLoading = true;
                      });
                      // await Future.delayed(Durations.extralong4);
                      await _handleLogin(context);
                      rebuild(() {
                        _isLoading = false;
                      });
                    },
                    radius: 15,
                    backgroundcolor: _isLoading
                        ? Colors.white.withOpacity(.6)
                        : Colors.white,
                    child: Text(
                      _isLoading ? 'Please wait..' : 'Continue',
                      style: TextStyle(
                          color: _isLoading
                              ? AppColors.primary.withOpacity(0.6)
                              : AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ));
              }),
              const Gap(20),
              // terms and conditions here
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      openTermsUrl(context);
                    },
                    child: const Text(
                      "Terms for use",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () async {},
                    child: const Text(
                      "Privacy Policy",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
