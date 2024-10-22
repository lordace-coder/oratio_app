import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

enum SelectedDateType { today, tommorrow, custom }

enum SelectedTimeType { morning, lateMorning, noon, afternoon }

class MassBookingPage extends StatefulWidget {
  const MassBookingPage({super.key});

  @override
  State<MassBookingPage> createState() => _MassBookingPageState();
}

class _MassBookingPageState extends State<MassBookingPage> {
  SelectedDateType? massDate;

  SelectedTimeType? massTime;

  bool selectedDateById(int id) {
    if (massDate == null) return false;
    return SelectedDateType.values[id - 1] == massDate;
  }

  bool selectedTimeById(int id) {
    if (massTime == null) return false;

    return SelectedTimeType.values[id - 1] == massTime;
  }

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
                Align(
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DateItemButton(
                          selected: selectedDateById(1),
                          date: 'Oct 1',
                          title: 'Today',
                          onTap: () {
                            setState(() {
                              massDate = SelectedDateType.values[0];
                            });
                          },
                        ),
                        DateItemButton(
                          onTap: () {
                            setState(() {
                              massDate = SelectedDateType.values[1];
                            });
                          },
                          selected: selectedDateById(2),
                          date: 'Oct 1',
                          title: 'Tommorrow',
                        ),
                        DateItemButton(
                          onTap: () {
                            setState(() {
                              massDate = SelectedDateType.values[2];
                            });
                          },
                          selected: selectedDateById(3),
                          date: '...',
                          title: 'Custom',
                        ),
                      ],
                    ),
                  ),
                ),

                const Gap(20),
                Column(
                  children: [
                    Row(
                      children: [
                        MassTimeButton(
                          time: '8:00 AM',
                          mass: 'Morning Mass',
                          selected: selectedTimeById(1),
                          onTap: () {
                            setState(() => massTime = SelectedTimeType.morning);
                          },
                        ),
                        MassTimeButton(
                          time: '10:00 AM',
                          mass: 'Late Morning Mass',
                          selected: selectedTimeById(2),
                          onTap: () {
                            setState(
                                () => massTime = SelectedTimeType.lateMorning);
                          },
                        ),
                      ],
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        MassTimeButton(
                          selected: selectedTimeById(3),
                          onTap: () {
                            setState(() => massTime = SelectedTimeType.noon);
                          },
                          time: '12:00 PM',
                          mass: 'Noon Mass',
                        ),
                        MassTimeButton(
                          selected: selectedTimeById(4),
                          onTap: () {
                            setState(() {
                              massTime = SelectedTimeType.afternoon;
                            });
                          },
                          time: '2:00 PM',
                          mass: 'Afternoon Mass',
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(10),
                Builder(builder: (context) {
                  bool disabledButton = massDate == null || massTime == null;
                  return Opacity(
                    opacity: disabledButton ? 0.4 : 1,
                    child: SubmitButtonV1(
                        radius: 10,
                        ontap: () {
                          if (disabledButton) {
                            // TODO run some code if the button is disabled for example prompt user to insert date and time
                            return;
                          }
                          context.pushNamed(RouteNames.massDetail);
                        },
                        backgroundcolor: AppColors.primary,
                        child: const Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        )),
                  );
                }),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select A Parish Or Mass Center',
                      style: TextStyle(fontSize: 17),
                    ),
                    GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteNames.parishpage);
                        },
                        child: Text(
                          'see more',
                          style:
                              TextStyle(fontSize: 13, color: AppColors.primary),
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
              context.pushNamed(RouteNames.parishpage);
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
