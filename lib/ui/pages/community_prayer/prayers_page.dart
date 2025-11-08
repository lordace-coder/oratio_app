import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

import 'package:go_router/go_router.dart';

class PrayersPage extends StatefulWidget {
  final String prayerText;
  final String prayerTitle;

  const PrayersPage({
    super.key,
    required this.prayerText,
    this.prayerTitle = "Community Prayer",
  });

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isReading = true;
  bool _isPaused = false;
  bool _isInitialized = false;
  Timer? _userCountTimer;
  Timer? _scrollTimer;

  int _currentCharStart = 0;
  int _currentCharEnd = 0;
  int _resumeOffset = 0; // Track offset when resuming from pause
  List<String> _lines = [];
  int _currentLineIndex = 0;
  int _liveUserCount = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _shimmerController;
  late AnimationController _userPulseController;

  @override
  void initState() {
    super.initState();
    _lines = widget.prayerText.split('\n');
    _initializeAnimations();
    _initializeTts();
    _startAutoScroll();
    _startUserCountSimulation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _userPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController.forward();
  }

  void _startUserCountSimulation() {
    _liveUserCount = 2 + Random().nextInt(1);
    _userCountTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        setState(() {
          final change = Random().nextInt(7) - 3;
          _liveUserCount = max(10, _liveUserCount + change);
        });
      }
    });
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.35);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setProgressHandler((text, start, end, word) {
      if (mounted) {
        setState(() {
          // Adjust positions based on resume offset
          _currentCharStart = start + _resumeOffset;
          _currentCharEnd = end + _resumeOffset;

          // Calculate which line we're on based on character position
          int charCount = 0;
          for (int i = 0; i < _lines.length; i++) {
            final lineLength = _lines[i].length + 1; // +1 for newline
            if (charCount + lineLength > _currentCharStart) {
              if (_currentLineIndex != i) {
                _currentLineIndex = i;
              }
              break;
            }
            charCount += lineLength;
          }
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        _scrollTimer?.cancel();
        setState(() {
          _isReading = false;
          _isPaused = false;
          _currentCharStart = 0;
          _currentCharEnd = 0;
          _currentLineIndex = 0;
          _resumeOffset = 0;
        });
        _showPrayerCompleteDialog();
      }
    });

    setState(() {
      _isInitialized = true;
    });

    if (_isReading) {
      await _flutterTts.speak(widget.prayerText);
    }
  }

  void _showPrayerCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF87CEEB),
                Color(0xFF00BFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF87CEEB).withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Prayer Complete',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your prayers have been lifted up 🙏',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Amen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF087395),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients && _isReading && !_isPaused) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll < maxScroll) {
          _scrollController.animateTo(
            currentScroll + 0.5, // Slow, steady scroll speed
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<void> _toggleReading() async {
    if (_isPaused) {
      // Resume from pause - continue from where we paused
      setState(() {
        _isPaused = false;
        // Set the offset so progress handler knows where we resumed from
        _resumeOffset = _currentCharEnd;
      });
      // Resume scrolling
      _startAutoScroll();
      // Continue speaking from where we left off
      await _flutterTts.speak(
        widget.prayerText.substring(_currentCharEnd),
      );
    } else {
      setState(() {
        _isReading = !_isReading;
      });

      if (_isReading) {
        // Start reading from beginning
        _resumeOffset = 0; // Reset offset when starting fresh
        _startAutoScroll();
        await _flutterTts.speak(widget.prayerText);
      } else {
        // Stop reading
        _scrollTimer?.cancel();
        await _flutterTts.stop();
        setState(() {
          _currentCharStart = 0;
          _currentCharEnd = 0;
          _currentLineIndex = 0;
          _resumeOffset = 0;
        });
      }
    }
  }

  Future<void> _pauseReading() async {
    setState(() {
      _isPaused = true;
    });
    // Stop auto-scrolling when paused
    _scrollTimer?.cancel();
    await _flutterTts.pause();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer?.cancel();
    _userCountTimer?.cancel();
    _flutterTts.stop();
    _fadeController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _userPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A4D68),
              Color(0xFF088395),
              Color(0xFF05BFDB),
              Color(0xFF00FFCA),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildGlassAppBar(),
                  const SizedBox(height: 12),
                  _buildLiveCounter(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPrayerCard(),
                    ),
                  ),
                  _buildModernControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            _shimmerController.value,
            _glowController.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildGlassAppBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.prayerTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sacred Moment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF87CEEB),
                      Color.lerp(
                        const Color(0xFF87CEEB),
                        Colors.white,
                        _glowAnimation.value * 0.3,
                      )!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF87CEEB).withOpacity(
                        0.4 + (_glowAnimation.value * 0.4),
                      ),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCounter() {
    return AnimatedBuilder(
      animation: _userPulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00FF88).withOpacity(
                            0.3 + (_userPulseController.value * 0.4),
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_liveUserCount believers',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Praying together now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
            const Color(0xFFF0F8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF87CEEB).withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(),
              ),
            ),

            // Prayer content
            Column(
              children: [
                // Header decoration
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF87CEEB).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF87CEEB),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF87CEEB), Color(0xFF00BFFF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✝ Sacred Prayer ✝',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF87CEEB),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Prayer text
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                    child: _buildHighlightedLines(),
                  ),
                ),

                // Amen section
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(
                              const Color(0xFF87CEEB),
                              const Color(0xFF00BFFF),
                              _glowAnimation.value,
                            )!,
                            const Color(0xFF87CEEB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🙏',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Amen',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '🙏',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedLines() {
    int charCount = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _lines.asMap().entries.map((entry) {
        final line = entry.value;

        if (line.trim().isEmpty) {
          charCount += 1; // Account for newline
          return const SizedBox(height: 16);
        }

        final lineStartChar = charCount;
        final lineEndChar = charCount + line.length;
        charCount += line.length + 1; // +1 for newline

        // Check if current speech is within this line
        final isInLine = _isReading &&
            _currentCharStart < lineEndChar &&
            _currentCharEnd > lineStartChar;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isInLine
              ? _buildHighlightedText(line, lineStartChar)
              : Text(
                  line,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.8,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.left,
                ),
        );
      }).toList(),
    );
  }

  Widget _buildHighlightedText(String line, int lineStartChar) {
    final spans = <TextSpan>[];

    for (int i = 0; i < line.length; i++) {
      final charPosition = lineStartChar + i;
      final isHighlighted =
          charPosition >= _currentCharStart && charPosition < _currentCharEnd;

      spans.add(
        TextSpan(
          text: line[i],
          style: TextStyle(
            fontSize: 19,
            height: 1.8,
            color: isHighlighted ? Colors.white : const Color(0xFF2C3E50),
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.4,
            backgroundColor:
                isHighlighted ? const Color(0xFF87CEEB).withOpacity(0.8) : null,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildModernControls() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildControlButton(
              icon: _isReading && !_isPaused
                  ? Icons.graphic_eq
                  : _isPaused
                      ? Icons.play_arrow
                      : Icons.volume_up,
              label: _isReading && !_isPaused
                  ? 'Reading'
                  : _isPaused
                      ? 'Resume'
                      : 'Listen',
              isActive: _isReading,
              onTap: _isInitialized ? _toggleReading : null,
              activeColor: const Color(0xFF87CEEB),
            ),
          ),
          if (_isReading && !_isPaused) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildControlButton(
                icon: Icons.pause,
                label: 'Pause',
                isActive: false,
                onTap: _pauseReading,
                activeColor: const Color(0xFFFF9800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    activeColor,
                    Color.lerp(activeColor, Colors.white, 0.3)!,
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;
  final double glow;

  BackgroundPainter(this.animation, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating circles
    final random = Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY - (animation * 50)) % size.height;
      final radius = random.nextDouble() * 40 + 20;

      paint.color =
          Colors.white.withOpacity(0.05 + (random.nextDouble() * 0.05));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Sparkles
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height + (animation * 100)) % size.height;
      final dotSize = random.nextDouble() * 3 + 1;

      paint.color = Colors.white.withOpacity(0.6 * glow);
      canvas.drawCircle(Offset(x, y), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB).withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Subtle grid pattern
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) => false;
}
