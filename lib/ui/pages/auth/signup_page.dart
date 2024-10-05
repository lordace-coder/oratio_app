import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

// ignore: must_be_immutable
class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  bool _isLoading = false;

  showSnackBar({required BuildContext context, required String message}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

  bool isValid(BuildContext context) {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showSnackBar(
          context: context, message: 'Please fill in the required fields');
      return false;
    }
    if (passwordController.text != confirmPassword.text) {
      showSnackBar(
        context: context,
        message: 'Password does not match confirm password',
      );
      return false;
    }
    if (passwordController.text.length < 7) {
      showSnackBar(
          context: context, message: 'Password cant be less than 7 characters');
      return false;
    }
    return true;
  }

  Future<void> handleSignup(BuildContext context) async {
    // todo handle loading
    if (!isValid(context)) return;
    // Map<String, String> data = {
    //   "email": emailController.text,
    //   "password": passwordController.text,
    //   "username": usernameController.text,
    //   "referral_code": referralController.text,
    // };
    // final response = await signup(data);
    // if (response.containsKey('error')) {
    //   // handle error
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('${response['error_message']}')));
    //   return;
    // } else {
    //   BlocProvider.of<AuthBloc>(context).add(
    //     AuthSubmitEvent(
    //       access: response['access'],
    //       refresh: response['refresh'],
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Create Your Account!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Gap(20),
              TextFieldd(
                controller: usernameController,
                hintText: 'e.g johndoe',
                isPassword: false,
                labeltext: 'Username',
              ),
              const Gap(10),
              TextFieldd(
                controller: firstNameController,
                hintText: 'Your FirstName here',
                isPassword: false,
                labeltext: 'First Name',
              ),
              const Gap(10),
              TextFieldd(
                controller: lastNameController,
                hintText: 'Your Last Name Here',
                isPassword: false,
                labeltext: 'Last Name',
              ),
              const Gap(10),
              TextFieldd(
                controller: emailController,
                hintText: 'e.g johndoe@gmail.com',
                isPassword: false,
                labeltext: 'Email Address',
                inputType: TextInputType.emailAddress,
              ),
              const Gap(10),
              TextFieldd(
                controller: phoneController,
                hintText: 'e.g 090124....',
                isPassword: false,
                labeltext: 'Phone Number',
                inputType: TextInputType.phone,
              ),
              const Gap(10),
              TextFieldd(
                controller: passwordController,
                hintText: 'must contain 8 or more characters',
                isPassword: true,
                labeltext: 'Password',
              ),
              const Gap(10),
              TextFieldd(
                controller: confirmPassword,
                hintText: 'must contain 8 or more characters',
                isPassword: true,
                labeltext: 'Confirm Password',
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(RouteNames.login);
                    },
                    child: Text(
                      ' login!',
                      style: TextStyle(color: AppColors.green),
                    ),
                  )
                ],
              ),
              const Gap(10),
              StatefulBuilder(builder: (context, rebuild) {
                return SubmitButtonV1(
                    ontap: () async {
                      if (_isLoading) return;
                      rebuild(() {
                        _isLoading = true;
                      });
                      // await Future.delayed(Durations.extralong4);
                      await handleSignup(context);

                      rebuild(() {
                        _isLoading = false;
                      });
                    },
                    radius: 15,
                    backgroundcolor: _isLoading
                        ? Colors.white.withOpacity(.6)
                        : Colors.white,
                    child: Text(
                      _isLoading ? 'Please wait..' : 'Register',
                      style: TextStyle(
                          color: _isLoading
                              ? AppColors.primary.withOpacity(0.6)
                              : AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ));
              }),
              const Gap(20),
            ],
          ),
        ),
      )),
    );
  }
}
