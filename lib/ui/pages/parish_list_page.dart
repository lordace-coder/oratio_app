import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
// import 'package:oratio_app/ui/widgets/church_widgets.dart';

class ParishListPage extends StatelessWidget {
  const ParishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // app bar
                appBar(context),


                const Gap(20),
                CustomSearchBar(controller: controller),
                const Gap(20),
                const ChurchListTile(),
                const ChurchListTile(),
                const ChurchListTile(),
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
              'Mass Centers',
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
