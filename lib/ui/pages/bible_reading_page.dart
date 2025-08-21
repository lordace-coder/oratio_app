import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oratio_app/bloc/bible_readings/bible_reading_service.dart';
import 'package:oratio_app/bloc/bible_readings/bible_verse.dart';
import 'package:oratio_app/ui/bright/pages/create_community.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BibleReadingPage extends StatefulWidget {
  const BibleReadingPage({super.key});

  @override
  _BibleReadingPageState createState() => _BibleReadingPageState();
}

class _BibleReadingPageState extends State<BibleReadingPage>
    with SingleTickerProviderStateMixin {
  int index = 0;
  bool loading = false;
  final List<BibleVerse> verses = [];
  String? _lastUpdateTime;
  late AnimationController _animationController;
  late Animation<double> _animation;

  Future<void> getBibleVerses() async {
    setState(() {
      loading = true;
    });
    try {
      final bibleService = BibleReadingService();
      final data = await bibleService.getReadings();
      _lastUpdateTime = await bibleService.getLastUpdateTimeAgo();
      verses.clear(); // Clear existing verses before adding new ones
      for (var verse in data) {
        verses.add(BibleVerse.fromJson(verse));
      }
    } catch (e) {
      // Handle error appropriately
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    getBibleVerses();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animation =
        Tween<double>(begin: 0, end: index / (verses.length - 1) * 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: true,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 20, color: AppColors.primary),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Daily Scripture',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -50,
                              top: -20,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekly Progress Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Daily Progress',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.blueDim,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: AnimatedBuilder(
                                        animation: _animation,
                                        builder: (context, child) {
                                          return Text(
                                            '${_animation.value.toInt()}%',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                LinearPercentIndicator(
                                  width: MediaQuery.of(context).size.width - 80,
                                  animation: true,
                                  lineHeight: 12.0,
                                  animationDuration: 2000,
                                  percent: (index / (verses.length - 1)),
                                  barRadius: const Radius.circular(6),
                                  progressColor: AppColors.blue,
                                  backgroundColor: AppColors.inputBoxGray,
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        color: AppColors.textDarkDim, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Updated : $_lastUpdateTime',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textDarkDim,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Current Reading Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        '${verses[index].reference}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        _buildIconButton(Icons.share_outlined,
                                            onTap: () {
                                          // share current bible reading
                                          final params = {
                                            "heading": verses[index].reference,
                                            "verse": verses[index].text
                                          };
                                          context.pushNamed(
                                              RouteNames.shareBiblePassage,
                                              extra: params);
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  verses[index].text!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Navigation Controls
                          Row(
                            children: [
                              Expanded(
                                child: _buildNavigationButton(
                                  icon: Icons.arrow_back_ios,
                                  label: 'Previous',
                                  onPressed: () {
                                    setState(() {
                                      if (index == 0) return;
                                      index -= 1;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNavigationButton(
                                  icon: Icons.arrow_forward_ios,
                                  label: 'Next',
                                  onPressed: () {
                                    setState(() {
                                      if (index == (verses.length - 1)) return;
                                      index += 1;
                                    });
                                  },
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.inputBoxGray,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.textDarkDim,
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: AppColors.primary),
        ),
        elevation: isPrimary ? 8 : 0,
        shadowColor:
            isPrimary ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isPrimary) Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (isPrimary) Icon(icon, size: 16),
        ],
      ),
    );
  }
}
