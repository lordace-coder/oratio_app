import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class ParishLandingPage extends StatelessWidget {
  const ParishLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image with text overlay

                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      height: 300,
                      decoration: const BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0, left: 15),
                      child: Text(
                        'St Patrick Cathedral',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(10),
                      const Text('led by Rev John Ezechukwu'),
                      Row(
                        children: [
                          const Text(
                            '+1000 Members',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Expanded(child: Container()),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                FontAwesomeIcons.solidStar,
                                color: Colors.yellow,
                              ),
                              Gap(4),
                              Text('4.5',
                                  style: TextStyle(
                                    fontSize: 18,
                                  )),
                              Text(
                                '/5',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              )
                            ],
                          ),
                        ],
                      ),
                      const Gap(20),
                      const Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.locationPin,
                            size: 13,
                          ),
                          Gap(10),
                          Expanded(
                            child: Text(
                              'Along old road Awka Onitsha Express road Anambra State',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Text(
                              "Are you interested in viewing our parish activities such as events and more click ",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              'here',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                      // Expanded(child: Container()),
                      const Gap.expand(20),
                      Row(
                        children: [
                          Expanded(
                            child: SubmitButtonV1(
                                radius: 10,
                                backgroundcolor: AppColors.primary,
                                child: const Text(
                                  'Donate Now',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                )),
                          ),
                          const Gap(10),
                          Expanded(
                            child: SubmitButtonV1(
                                radius: 10,
                                backgroundcolor: Colors.white,
                                isOutline: true,
                                outlineColor: AppColors.primary,
                                child: Text(
                                  'Join Parish',
                                  style: TextStyle(
                                      color: AppColors.primary, fontSize: 17),
                                )),
                          )
                        ],
                      ),
                      const Gap(10),
                      SubmitButtonV1(
                          radius: 10,
                          backgroundcolor: AppColors.primary,
                          child: const Text(
                            'Book Mass',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ))
                    ],
                  ),
                )
              ],
            ),

            // app bar
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: const Icon(
                            FontAwesomeIcons.chevronLeft,
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [],
                          padding: EdgeInsets.zero,
                          iconColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
