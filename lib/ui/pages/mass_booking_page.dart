import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class MassBookingPage extends StatelessWidget {
  const MassBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // app bar
                appBar(context),
                // TODO check if item is selected before displaying purple [appcolors primary] or white as bg for button
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DateItemButton(
                          selected: false,
                          date: 'Oct 1',
                          title: 'Today',
                        ),
                        DateItemButton(
                          selected: false,
                          date: 'Oct 1',
                          title: 'Tommorrow',
                        ),
                        DateItemButton(
                          selected: true,
                          date: '...',
                          title: 'Custom',
                        ),
                      ],
                    ),
                  ),
                ),

                const Gap(20),
                const Column(
                  children: [
                    Row(
                      children: [
                        MassTimeButton(
                          time: '8:00 AM',
                          mass: 'Morning Mass',
                        ),
                        MassTimeButton(
                          time: '10:00 AM',
                          mass: 'Late Morning Mass',
                        ),
                      ],
                    ),
                    Gap(20),
                    Row(
                      children: [
                        MassTimeButton(
                          time: '12:00 PM',
                          mass: 'Noon Mass',
                        ),
                        MassTimeButton(
                          time: '2:00 PM',
                          mass: 'Afternoon Mass',
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(10),
                SubmitButtonV1(
                    radius: 10,
                    ontap: () {
                      context.pushNamed(RouteNames.massDetail);
                    },
                    backgroundcolor: AppColors.primary,
                    child: const Text(
                      'Book Now',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    )),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select A Parish Or Mass Center',
                      style: TextStyle(fontSize: 17),
                    ),
                    GestureDetector(
                        child: Text(
                      'see more',
                      style: TextStyle(fontSize: 13, color: AppColors.primary),
                    ))
                  ],
                ),
                const Gap(10),
                CustomSearchBar(controller: controller),
                const Gap(20),
                // const ChurchListTile(),
                // const ChurchListTile(),
                // const ChurchListTile(),
                const NoParishYet()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row appBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: const Icon(
                FontAwesomeIcons.chevronLeft,
                size: 18,
              ),
            ),
            const Gap(30),
            const Text(
              'Book Mass',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
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
    );
  }
}

class NoParishYet extends StatelessWidget {
  const NoParishYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        children: [
          const Icon(
            FontAwesomeIcons.wineGlassEmpty,
            size: 30,
          ),
          const Gap(20),
          const Text(
            'Churches You Have Joined Will Be Displayed Here',
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          MaterialButton(
            animationDuration: Durations.extralong2,
            onPressed: () {
              context.pushNamed(RouteNames.massDetail);
            },
            color: AppColors.green,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.church,
                  color: Colors.white,
                  size: 14,
                ),
                Gap(10),
                Text(
                  'Join Church',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
