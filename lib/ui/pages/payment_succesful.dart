import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

enum PaymentStatus { succesful, failed }

class PaymentSuccesful extends StatelessWidget {
  const PaymentSuccesful({super.key, required this.paymentStatus});
  final PaymentStatus paymentStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: const Icon(FontAwesomeIcons.chevronLeft)),
      ),
      body:paymentStatus == PaymentStatus.succesful? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const Row(),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      color: AppColors.greenDisabled,
                      borderRadius: BorderRadius.circular(10000)),
                ),
                Positioned(
                  // // top: 0,
                  // left: 30,
                  // right: 30,
                  // // bottom: 0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10000)),
                    child: const Icon(
                      FontAwesomeIcons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const Gap(60),
            const Text(
              'Payment Succesful',
              style: TextStyle(fontSize: 20),
            ),
            const Gap(30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'you have succesfully donated \$30.23 to this parish remain blessed',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            Expanded(child: Container()),
            SubmitButtonV1(
                ontap: () {
                  context.pushNamed(RouteNames.homePage);
                },
                radius: 12,
                backgroundcolor: AppColors.primary,
                child: const Text(
                  'Back to App',
                  style: TextStyle(color: Colors.white),
                )),
            const Gap(20),
          ],
        ),
      ):Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const Row(),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      color: AppColors.greenDisabled,
                      borderRadius: BorderRadius.circular(10000)),
                ),
                Positioned(
                  // // top: 0,
                  // left: 30,
                  // right: 30,
                  // // bottom: 0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10000)),
                    child: const Icon(
                      FontAwesomeIcons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const Gap(60),
            const Text(
              'Payment Succesful',
              style: TextStyle(fontSize: 20),
            ),
            const Gap(30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'you have succesfully donated \$30.23 to this parish remain blessed',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            Expanded(child: Container()),
              SubmitButtonV1(
                ontap: () {
                  context.pushNamed(RouteNames.homePage);
                },
                radius: 12,
                backgroundcolor: AppColors.primary,
                child: const Text(
                  'Contact Dev Team',
                  style: TextStyle(color: Colors.white),
                )),
            SubmitButtonV1(
                ontap: () {
                  context.pushNamed(RouteNames.homePage);
                },
                radius: 12,
                backgroundcolor: AppColors.primary,
                child: const Text(
                  'Back to App',
                  style: TextStyle(color: Colors.white),
                )),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}
