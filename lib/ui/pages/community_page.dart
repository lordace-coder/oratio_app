import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: ListView(
          children: const [
            CommunityListItem(),
            CommunityListItem(),
            CommunityListItem(),
            CommunityListItem(),
          ],
        ),
      ),
    );
  }

  ///RETURNS APPBAR WIDGET
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.gray,
      toolbarHeight: 80,
      leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            FontAwesomeIcons.chevronLeft,
          )),
      title: const Text('Prayer Communities'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.person_add))
      ],
    );
  }
}

class CommunityListItem extends StatelessWidget {
  const CommunityListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO enter inside community
        context.pushNamed(RouteNames.communityDetailPage);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const CircleAvatar(
                  radius: 20,
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Text(
                              'Sacred heart society Sacred heart society',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Text(
                            '04:12AM',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textDarkDim),
                          ),
                        ],
                      ),
                      const Text(
                        'Paul: Greeting children of God',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
