import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.gray.withOpacity(.5),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        FontAwesomeIcons.search,
                        // color: theme.titleColor,
                        size: 13,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontSize: 15),
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w400),
                          hintText: 'Search here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // a few widget like stories to show prayers of friends and family

              // chats
              const ChatItem(),
              const ChatItem(),
              const ChatItem(),

              const ChatItem(),
              const ChatItem(),
              const ChatItem(),
              const ChatItem(),
              const ChatItem(),
              const ChatItem(),
              const ChatItem(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatItem extends StatefulWidget {
  const ChatItem({
    super.key,
  });

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, -0.2),
    ).animate(animationController);

    // animationController.addStatusListener( (status) {
    //   if (status == AnimationStatus.completed) {
    //     animationController.();
    //   }
    // });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          context.pushNamed(RouteNames.chatDetailPage);
        },
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      animationController.forward();
                    },
                    child: const Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        // backgroundColor: theme.primary.withOpacity(0.6),
                        radius: 20,
                        child: Icon(
                          Icons.person,
                          // color: theme.subtitleColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const Gap(11),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                            // color: theme.chatInoutColor!.withOpacity(0.7),

                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Gap(6),
                      Text(
                        '~ some message here',
                        style: TextStyle(
                            // color: theme.shadePrimary.withOpacity(0.8),
                            ),
                      )
                    ],
                  )
                ],
              ),
              const Text(
                '15 mins ago',
                style: TextStyle(
                  fontSize: 12,
                  // color: theme.shadePrimary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
