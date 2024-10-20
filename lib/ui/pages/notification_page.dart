import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray,
      appBar: createAppBar(actions: [
        PopupMenuButton(itemBuilder: (context) {
          return [
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.trash,
                    color: Colors.black54,
                  ),
                  Gap(7),
                  Text(
                    'Delete All',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ),
          ];
        })
      ], label: 'Notifications'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView(children: const [
          Gap(20),
          Text(
            'Recent',
            style: TextStyle(
              color: Colors.black45,
            ),
          ),
          Gap(10),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
        ]),
      ),
    );
  }

 
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        startActionPane: ActionPane(motion: const ScrollMotion(), children: [
          SlidableAction(
            onPressed: (context) {},
            icon: Icons.remove_red_eye,
            label: 'Mark Seen',
            backgroundColor: Colors.blue[400]!,
            foregroundColor: Colors.white70,
          )
        ]),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {},
              icon: Icons.delete,
              label: 'Delete',
              backgroundColor: Colors.red[400]!,
              foregroundColor: Colors.white70,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(FontAwesomeIcons.microphone),
              Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Mass Booked Succesfully, You will be noticed for the mass schedule',
                    ),
                    Text(
                      '12:12pm',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
