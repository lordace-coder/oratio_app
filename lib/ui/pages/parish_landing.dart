import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/networkProvider/requests.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/servces.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/buttons.dart';

class ParishLandingPage extends StatefulWidget {
  const ParishLandingPage({super.key, required this.parishId});

  final String parishId;

  @override
  State<ParishLandingPage> createState() => _ParishLandingPageState();
}

class _ParishLandingPageState extends State<ParishLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: getParish(context, id: widget.parishId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final data = snapshot.data!;
              final parishMember =
                  isParishMember(church: data, context: context);
              final pb = getPocketBaseFromContext(context);
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section with Gradient Overlay
                        Container(
                          height: 380,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Stack(
                            children: [
                              // Background Image with Gradient Overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF8E2DE2),
                                      AppColors.primary.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                              ),
                              // Content Overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                  image: DecorationImage(
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(.5),
                                          BlendMode.darken),
                                      image: CachedNetworkImageProvider(pb
                                          .getFileUrl(data,
                                              data.getStringValue('image'))
                                          .toString()),
                                      fit: BoxFit.cover),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                              ),
                              // Community Details
                              Positioned(
                                bottom: 32,
                                left: 24,
                                right: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.getStringValue('name').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const Gap(8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.userGroup,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const Gap(8),
                                              Text(
                                                '${data.getListValue('members').length} ${data.getListValue('members').length > 1 ? 'Members' : 'Member'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Leader Section
                        Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8E2DE2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(pb
                                          .getFileUrl(
                                              data.expand['priest']!.first,
                                              data.expand['priest']!.first
                                                  .getStringValue('avatar'))
                                          .toString()),
                                      fit: BoxFit.cover),
                                ),
                                child: data.expand['priest']!.first
                                        .getStringValue('avatar')
                                        .isEmpty
                                    ? const Icon(
                                        FontAwesomeIcons.userTie,
                                        color: Color(0xFF8E2DE2),
                                        size: 24,
                                      )
                                    : null,
                              ),
                              const Gap(16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Parish Priest',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    getFullName(data.expand['priest']!.first),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Description Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(10),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  data.getStringValue('description'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Gap(20),

                        // Join Button
                        Container(
                          margin: const EdgeInsets.all(24),
                          child: buildGradientButton(
                            parishMember ? 'My Parish' : 'Join Parish',
                            FontAwesomeIcons.userPlus,
                            () async {
                              //check if user is attending parish
                              if (parishMember) {
                                return NotificationService.showWarning(
                                    'Already a Parish Member',
                                    duration: const Duration(seconds: 4));
                              }
                              //  TODO join parish here
                              await joinParish(context, id: widget.parishId);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Custom App Bar
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.chevronLeft,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 400,
                child: Lottie.asset('assets/lottie/anim1.json'),
              );
            }
            return Container();
          }),
    );
  }
}
