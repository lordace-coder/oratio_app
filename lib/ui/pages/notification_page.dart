import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:oratio_app/bloc/notifications_cubit/notifications_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/church_widgets.dart';
import 'package:pocketbase/pocketbase.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    if (context.read<NotificationCubit>().state is NotificationLoaded) {
      if ((context.read<NotificationCubit>().state as NotificationLoaded)
          .notifications
          .isEmpty) {
        return;
      }
      context
          .read<NotificationCubit>()
          .handleNotificationAction(NotificationAction.read);
    }
  }

  @override
  Widget build(BuildContext context) {
    // load notifications if its not loaded
    final notificationState = context.read<NotificationCubit>().state;
    if (notificationState is! NotificationLoaded) {
      context.read<NotificationCubit>().fetchNotifications();
    }
    return Scaffold(
        backgroundColor: AppColors.gray,
        appBar: createAppBar(context,
            actions: [
              PopupMenuButton(itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () async {
                      await context
                          .read<NotificationCubit>()
                          .deleteAllNotifications();
                    },
                    child: const Row(
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
            ],
            label: 'Notifications'),
        body: BlocConsumer<NotificationCubit, NotificationState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/bell.json', height: 200),
                      const Text(
                        'No Notifications Yet',
                        style: TextStyle(color: Colors.black45, fontSize: 18),
                      )
                    ],
                  ),
                );
              } else {
                // there are notifications
                final data = state.notifications;
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    await context
                        .read<NotificationCubit>()
                        .fetchNotifications();
                    context.read<NotificationCubit>().realtimeConnection();
                  },
                  child: ListView.builder(
                    itemCount: state.notifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      return NotificationItem(data: data[index]);
                    },
                  ),
                );
              }
            } else if (state is NotificationLoading) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(),
                    Lottie.asset(
                        height: 200,
                        'assets/lottie/anim1.json',
                        options:
                            LottieOptions(enableApplyingOpacityToLayers: true)),
                  ],
                ),
              );
            }
            return Container(
              child: const Text('data'),
            );
          },
        ));
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.data,
  });
  final RecordModel data;
  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
    return Container(
      // margin: const EdgeInsets.only(bottom: 5),
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
              onPressed: (context) async {
                await context
                    .read<NotificationCubit>()
                    .deleteNotification(data.id);
              },
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
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: data.getBoolValue('read') ? Colors.white : Colors.blue[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(FontAwesomeIcons.microphone),
              const Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // title
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        style: const TextStyle(fontSize: 17),
                        data.getStringValue('title'),
                      ),
                    ),
                    // notification
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        data.getStringValue('notification'),
                      ),
                    ),
                    Text(
                      formatDateTimeToHoursAgo(format.parse(data.created)),
                      style: const TextStyle(
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
