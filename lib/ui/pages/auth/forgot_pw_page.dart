import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:oratio_app/networkProvider/constants.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
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

  void showError(BuildContext context, String error) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        showCloseIcon: true,
        backgroundColor: Colors.red[400],
      ));

  void showSuccess(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ),
        showCloseIcon: true,
        backgroundColor: Colors.green,
      ));

  Future generateToken(BuildContext context) async {
    // check if email is null
    if (emailController.text.isEmpty) {
      showError(context, 'Enter a valid email first');
      return;
    }
    try {} on DioException catch (e) {
      print(e.response!.data);
      showError(context, 'Invalid Email, account doesnt exist');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
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
                email: email!,
              ),
      )),
    );
  }
}

class SendEmailScreen extends StatelessWidget {
  const SendEmailScreen(
      {super.key,
      required this.controller,
      required this.isLoading,
      required this.onSubmit});
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    final emailController = controller;

    return ListView(children: [
      const Gap(30),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Change Password',
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Gap(20),
          const Text('let\'s help you recover your account',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const Gap(20),
          const Text(
              'you will recieve a recovery token in your email\nNote: if email isnt found check your spam folder',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const Gap(50),
          TextFieldd(
            labeltext: 'Email',
            hintText: 'Enter your email here',
            controller: emailController,
            isPassword: false,
            inputType: TextInputType.emailAddress,
          ),
          const Gap(20),
          StatefulBuilder(builder: (context, rebuild) {
            return SubmitButtonV1(
                ontap: () {
                  onSubmit();
                },
                radius: 15,
                backgroundcolor:
                    isLoading ? Colors.white.withOpacity(.6) : Colors.white,
                child: Text(
                  isLoading ? 'Please wait..' : 'Get Email',
                  style: TextStyle(
                      color: isLoading
                          ? AppColors.primary.withOpacity(0.6)
                          : AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ));
          }),
        ],
      ),
      const Gap(40),
    ]);
  }
}

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key, required this.email});
  final TextEditingController token = TextEditingController();
  final TextEditingController password = TextEditingController();
  final String email;

  bool _isLoading = false;

  void showError(BuildContext context, String error) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        showCloseIcon: true,
        backgroundColor: Colors.red[400],
      ));

  void showSuccess(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ),
        showCloseIcon: true,
        backgroundColor: Colors.green,
      ));

  Future changePassword(BuildContext context) async {
    if (password.text.isEmpty || token.text.isEmpty) {
      showError(context, 'Password or token cannot be empty');
      return;
    }
    try {
      // final res = await dio.post('/recovery/$email',
      //     data: {'new_password': password.text, 'token': token.text});
      showSuccess(context, 'Changed Password succesfully');
      await Future.delayed(Durations.extralong4);
      context.pushNamed(RouteNames.login);
      return;
    } catch (e) {
      showError(context, 'Token is invalid or expired');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const Gap(30),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'New Password',
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Gap(20),
          const Text('Enter your new password',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const Gap(50),
          TextFieldd(
            labeltext: 'Token',
            hintText: 'Enter the token you saw in your email',
            controller: token,
            isPassword: false,
          ),
          const Gap(20),
          TextFieldd(
            labeltext: 'Password',
            hintText: 'Type in your new Password',
            controller: password,
            isPassword: true,
          ),
          const Gap(20),
          StatefulBuilder(builder: (context, rebuild) {
            return SubmitButtonV1(
                ontap: () async {
                  rebuild(() {
                    _isLoading = true;
                  });
                  await changePassword(context);
                  rebuild(() {
                    _isLoading = false;
                  });
                },
                radius: 15,
                backgroundcolor:
                    _isLoading ? Colors.white.withOpacity(.6) : Colors.white,
                child: Text(
                  _isLoading ? 'Please wait..' : 'Change Password',
                  style: TextStyle(
                      color: _isLoading
                          ? AppColors.primary.withOpacity(0.6)
                          : AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ));
          }),
        ],
      ),
      const Gap(40),
    ]);
  }
}
