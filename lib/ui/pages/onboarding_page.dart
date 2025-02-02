import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:oratio_app/ui/routes/routes.dart';
import 'package:oratio_app/ui/themes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Welcome to CathsApp",
      description: "Connect with Catholics all over the world.",
      img: "assets/images/onboarding/mass.png",
      backgroundColor: const Color(0xFFE3F2FD),
    ),
 
    OnboardingContent(
      title: "Get Started",
      description: "Find your Parish and Prayer Community today",
      img: "assets/images/onboarding/parish.png",
      backgroundColor: const Color(0xFFFCE4EC),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: _backgroundAnimation.value,
                    top: -100,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: _contents[_currentPage]
                            .backgroundColor
                            .withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -_backgroundAnimation.value,
                    bottom: -50,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _contents[_currentPage]
                            .backgroundColor
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () async {
                        // Navigate to main app
                        await markOpened();
                        context.push('/');
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemCount: _contents.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: OnboardingPage(
                              content: _contents[index],
                              index: index,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Animated Progress Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _contents.length,
                          (index) => buildDot(index),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Animated Buttons
                      ElasticIn(
                        duration: const Duration(milliseconds: 800),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: _currentPage == _contents.length - 1
                                ? _buildGetStartedButton()
                                : _buildNextButton(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return MouseRegion(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 1, end: 1.05),
        duration: const Duration(milliseconds: 200),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await markOpened();
                  context.push('/');
                },
                child: Text(
                  'Get Started',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Next',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0,
        end: _currentPage == index ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          width: 8 + (16 * value),
          height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.dimGray,
              AppColors.primary,
              value,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;
  final int index;

  const OnboardingPage({
    super.key,
    required this.content,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Added SingleChildScrollView
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated background circle
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: content.backgroundColor.withOpacity(0.2),
                      ),
                    ),
                  );
                },
              ),
              // Lottie animation
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: SizedBox(
                  height: 280,
                  child: Image.asset(content.img),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ShakeX(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 200),
            from: 10,
            child: Text(
              content.title,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 400),
            child: Text(
              content.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textDarkDim,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String img;
  final Color backgroundColor;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.img,
    required this.backgroundColor,
  });
}
