import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';

class ChurchListTile extends StatelessWidget {
  const ChurchListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          context.pushNamed(RouteNames.parishlanding);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black45),
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'St. Patrick ',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.locationPin,
                            size: 10,
                            color: AppColors.primary,
                          ),
                          const Gap(3),
                          Text(
                            '5th Ave. New York, NY',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDarkDim,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.gray),
                      child: const Center(
                          child: Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )),
                    ),
                  ),
                )
              ],
            ),
            const Divider()
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppColors.dimGray, borderRadius: BorderRadius.circular(5)),
      child: TextField(
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: Colors.black54,
        ),
        controller: controller,
        decoration: const InputDecoration(
            hintStyle:
                TextStyle(color: Colors.black45, fontWeight: FontWeight.normal),
            border: InputBorder.none,
            hintText: 'Search for a church or Mass center',
            prefixIcon: Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Colors.black45,
              size: 17,
            )),
      ),
    );
  }
}

class DateItemButton extends StatelessWidget {
  const DateItemButton({
    super.key,
    required this.selected,
    required this.title,
    required this.date,
    required this.onTap,
  });

  final VoidCallback onTap;
  final bool selected;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontSize: 17),
            ),
            Text(
              date,
              style:
                  TextStyle(color: selected ? Colors.white60 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class MassTimeButton extends StatelessWidget {
  const MassTimeButton({
    super.key,
    required this.time,
    required this.mass,
    required this.selected,
    required this.onTap,
  });

  final String time;
  final String mass;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                FontAwesomeIcons.clock,
                color: selected ? Colors.white : Colors.black,
              ),
              const Gap(5),
              Text(
                time,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
              Text(
                mass,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AppBar createAppBar(BuildContext context,
    {required String label,
    List<Widget>? actions,
    Color? foregroundColor,
    Color? backgroundColor}) {
  return AppBar(
    leading: GestureDetector(
        onTap: () {
          context.pop();
        },
        child: const Icon(FontAwesomeIcons.chevronLeft)),
    foregroundColor: foregroundColor ?? Colors.white,
    backgroundColor: backgroundColor ?? AppColors.primary,
    title: Text(label),
    actions: actions,
  );
}

void showGiveOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Give',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(FontAwesomeIcons.xmark),
              ),
            ],
          ),
          const Gap(24),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.handHoldingDollar,
            label: 'Give Offering',
            description: 'Support your parish',
            onTap: () {
              Navigator.pop(context);
              // Handle offering
            },
          ),
          const Gap(16),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.coins,
            label: 'Pay Tithes',
            description: '10% of your income',
            onTap: () {
              Navigator.pop(context);
              // Handle tithes
            },
          ),
          const Gap(16),
          buildGiveOption(
            context,
            icon: FontAwesomeIcons.seedling,
            label: 'Special Seed',
            description: 'Give for a specific cause',
            onTap: () {
              Navigator.pop(context);
              // Handle special seed
            },
          ),
        ],
      ),
    ),
  );
}

Widget buildGiveOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String description,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            FontAwesomeIcons.chevronRight,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    ),
  );
}


