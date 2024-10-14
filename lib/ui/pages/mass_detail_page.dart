import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/pages/auth/forgot_pw_page.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class MassDetailPage extends StatelessWidget {
  const MassDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 143, 19, 19),
      child: Scaffold(
        bottomSheet: MassBookBottomSheet(),
        backgroundColor: Colors.transparent,
        appBar: getAppBar(),
        body: const SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Gap(100),
            ],
          ),
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {},
        child: const Icon(FontAwesomeIcons.chevronLeft),
      ),
      backgroundColor: Colors.transparent,
      actions: [
        PopupMenuButton(
          padding: const EdgeInsets.all(0),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.solidBookmark,
                      color: Colors.black54,
                    ),
                    Gap(7),
                    Text(
                      'My Churches',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.church,
                      color: Colors.black54,
                    ),
                    Gap(7),
                    Text(
                      'All Churches',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
            ];
          },
        ),
      ],
      foregroundColor: Colors.white,
    );
  }
}

class MassBookBottomSheet extends StatelessWidget {
  MassBookBottomSheet({
    super.key,
  });
  final TextEditingController intention = TextEditingController();
  final TextEditingController attendees = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      //TODO remove this
      height: 420,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: ListView(
        children: [
          const Gap(20),
          const Row(),
          const Center(
            child: Text(
              'Book Mass',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.circleExclamation,
                color: AppColors.warning,
              ),
              const Gap(10),
              Text(
                'please read carefully before answering',
                style: TextStyle(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const Gap(10),
          TextFieldd(
            inputTextStyle: const TextStyle(color: Colors.black),
            labeltext: 'Intention',
            labelTextStyle: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                  color: Colors.black.withOpacity(.6),
                  fontWeight: FontWeight.normal),
              border: InputBorder.none,
            ),
            hintText: 'Describe the intention why you are booking the mass',
            controller: intention,
            isPassword: false,
          ),
          const Gap(10),
          TextFieldd(
            inputTextStyle: const TextStyle(color: Colors.black),
            labeltext: 'Names of attendees',
            labelTextStyle: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                  color: Colors.black.withOpacity(.6),
                  fontWeight: FontWeight.normal),
              border: InputBorder.none,
            ),
            hintText: 'Person for whom the mass is being offered',
            controller: intention,
            isPassword: false,
          ),
          //TODO ADD SELECTED DATE AND TIME DISPLAY
          const Gap(30),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Icon(
          //       FontAwesomeIcons.circleExclamation,
          //       color: AppColors.warning,
          //     ),
          //     const Gap(10),
          //     Text(
          //       'please donate to book a mass',
          //       style: TextStyle(
          //         color: AppColors.warning,
          //       ),
          //     ),
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: AppColors.green,
                size: 13,
              ),
              const Gap(7),
              Text(
                'God bless you for that gracious donation',
                style: TextStyle(color: AppColors.green, fontSize: 13),
              ),
            ],
          ),
          const Gap(10),
          SubmitButtonV1(
              ontap: () {
                context.pushNamed(RouteNames.paymentSuccesful);
              },
              radius: 12,
              backgroundcolor: AppColors.primary,
              child: const Text(
                'Donate now',
                style: TextStyle(color: Colors.white),
              )),
          const Gap(10),
          SubmitButtonV1(
              radius: 12,
              backgroundcolor: AppColors.greenDisabled,
              child: const Text(
                'Book Mass',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
