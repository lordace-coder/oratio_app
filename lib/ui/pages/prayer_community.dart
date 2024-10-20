import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class PrayerCommunityDetail extends StatelessWidget {
   PrayerCommunityDetail({super.key});

  double opacity = 1.0;

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
                        'Prayer Community',
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
                          // TODO implement stacks of profile image
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
                      const Text(
                        'Description:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Gap(10),
                      const Text(
                        "Rev. Knott & Rev. Burden preach verse by verse, chapter by chapter through books of the Bible. Their sermons are called",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      // Expanded(child: Container()),
                      const Gap.expand(40),
                      SubmitButtonV1(
                          radius: 10,
                          backgroundcolor: AppColors.green,
                          child: const Text(
                            'Join Community',
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
