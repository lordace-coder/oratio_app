import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/bloc/auth_bloc/cubit/pocket_base_service_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:oratio_app/helpers/url_launcher.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';
import 'package:pocketbase/pocketbase.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPassword = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;

  bool isValid(BuildContext context) {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showError(context, message: 'Please fill in the required fields');
      return false;
    }
    if (passwordController.text != confirmPassword.text) {
      showError(
        context,
        message: 'Password does not match confirm password',
      );
      return false;
    }
    if (passwordController.text.length < 7) {
      showError(context, message: 'Password cant be less than 7 characters');
      return false;
    }
    return true;
  }

  Future<void> handleSignup(BuildContext context) async {
    // todo handle loading
    if (!isValid(context)) return;
    try {
      final pb = context.read<PocketBaseServiceCubit>().state.pb;
      Map<String, dynamic> data = {
        "username": usernameController.text.trim().replaceAll(' ', ''),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "passwordConfirm": confirmPassword.text.trim(),
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "phone_number": phoneController.text.trim(),
      };
      pb.collection('users').create(body: data).then((_) {
        pb.collection('users').authWithPassword(
            emailController.text.trim(), passwordController.text.trim());
      }).catchError((err) {
        final error = err as ClientException;
        try {
          final firstError = error.response['data'].keys.first;
          showError(context,
              message: error.response['data'][firstError]['message']);
        } catch (e) {
          showError(context, message: 'Error occured during signup');
          return;
        }
      });
    } on ClientException {
      showError(context, message: 'Unknown Error occured during signup');
      return;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassword.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final pb = context.read<PocketBaseServiceCubit>();
    pb.state.pb.authStore.onChange.listen((event) {
      if (!pb.state.pb.authStore.isValid) {
        context.pushNamed(RouteNames.homePage);
        return;
      }
    });
    if (pb.state.pb.authStore.isValid) {
      context.pushNamed(RouteNames.homePage);
    }
  }

  List<Step> getSteps() {
    return [
      Step(
        title: const Text('Account Info'),
        content: Column(
          children: [
            TextFieldd(
              controller: usernameController,
              hintText: 'e.g johndoe',
              isPassword: false,
              labeltext: 'Username',
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
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Personal Info'),
        content: Column(
          children: [
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
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Password'),
        content: Column(
          children: [
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
          ],
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(20),
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
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Begin Your Spiritual Journey',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              SizedBox(
                height: 400, // Adjust the height as needed
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  connectorColor: WidgetStateProperty.all(AppColors.primary),
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              shape: const BeveledRectangleBorder(),
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text('Cancel',
                                style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );
                  },
                  onStepContinue: () {
                    if (_currentStep < getSteps().length - 1) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      handleSignup(context);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    }
                  },
                  steps: getSteps(),
                ),
              ),
              const Gap(10),
              const Gap(10),
              StatefulBuilder(builder: (context, rebuild) {
                return ElevatedButton(
                    onPressed: () async {
                      if (_isLoading) return;
                      rebuild(() {
                        _isLoading = true;
                      });
                      await handleSignup(context);

                      rebuild(() {
                        _isLoading = false;
                      });
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
                      _isLoading ? 'Please wait..' : 'Register',
                      style: TextStyle(
                          color: _isLoading
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ));
              }),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.goNamed(RouteNames.login);
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              ),
              const Gap(20),
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
                    onTap: () async {
                      openPolicyUrl(context);
                    },
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
            ],
          ),
        ),
      )),
    );
  }
}
