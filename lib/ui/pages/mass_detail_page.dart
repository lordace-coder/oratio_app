import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/inputs.dart';

class MassDetailPage extends StatelessWidget {
  const MassDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 143, 19, 19),
      child: Scaffold(
        bottomSheet: MassBookBottomSheet(),
        backgroundColor: Colors.transparent,
        appBar: getAppBar(),
        body: const SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Gap(100),
            ],
          ),
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {},
        child: const Icon(FontAwesomeIcons.chevronLeft),
      ),
      backgroundColor: Colors.transparent,
      actions: [
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
      foregroundColor: Colors.white,
    );
  }
}

class MassBookBottomSheet extends StatelessWidget {
  MassBookBottomSheet({
    super.key,
  });
  final TextEditingController intention = TextEditingController();
  final TextEditingController attendees = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500, //TODO remove this
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: Column(
        children: [
          const Gap(20),
          const Row(),
          const Text(
            'Book Mass',
            style: TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.exclamationCircle,
                color: AppColors.warning,
              ),
              const Gap(10),
              Text(
                'please read carefully before answering',
                style: TextStyle(
                  color: AppColors.warning,
                ),
              ),
              const Gap(30),
              TextFieldd(
                  labeltext: 'Intention',
                  hintText:
                      'Describe the intention why you are booking the mass',
                  controller: intention,
                  isPassword: false)
            ],
          )
        ],
      ),
    );
  }
}
