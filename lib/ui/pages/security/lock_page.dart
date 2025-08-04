import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:gap/gap.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/ui/themes.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  Future<void> unlockApp() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    try {
      if (canAuthenticate) {
        final result =
            await auth.authenticate(localizedReason: 'App Secured your funds');
        if (result) {
          AppLock.of(context)!.didUnlock();
        }
      } else {
        // user hasnt settup authentication yet

        AppLock.of(context)!.didUnlock();
      }
    } on PlatformException catch (e) {
      // user hasnt settup password on device
      AppLock.of(context)!.didUnlock();

      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Durations.extralong4).then((x) => unlockApp());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Row(),
            const Gap(20),
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'Login to Continue',
              style: TextStyle(color: Colors.black45),
            ),
            const Gap(10),
            TextButton(
                onPressed: () {
                  unlockApp();
                },
                child: const Text('Click here to unlock app')),
            Expanded(
                child: Lottie.asset('assets/lottie/fingerprint animation.json'))
          ],
        ),
      ),
    );
  }
}
