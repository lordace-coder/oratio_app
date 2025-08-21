import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ShareBiblePassage extends StatefulWidget {
  const ShareBiblePassage(
      {super.key, required this.heading, required this.verse});

  final String heading;
  final String verse;

  @override
  State<ShareBiblePassage> createState() => _ShareBiblePassageState();
}

class _ShareBiblePassageState extends State<ShareBiblePassage> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSharing = false;

  Future<void> sharePassage() async {
    setState(() {
      isSharing = true;
    });

    try {
      // Hide the share button temporarily
      await Future.delayed(const Duration(milliseconds: 100));

      final Uint8List? image = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/bible_verse.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '${widget.heading}\n\n"${widget.verse}"',
          subject: 'Bible Verse - ${widget.heading}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[25],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Screenshot(
                      controller: screenshotController,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightBlue.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decorative element
                              Container(
                                width: 60,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightBlue[400]!,
                                      Colors.lightBlue[600]!
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Bible verse text
                              Text(
                                '"${widget.verse}"',
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.6,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Reference
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightBlue[50]!,
                                      Colors.blue[50]!
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.lightBlue[100]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.heading,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.lightBlue[800],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // CathsApp branding and decorative icon
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.lightBlue[100]!,
                                          Colors.lightBlue[200]!
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_outlined,
                                      size: 18,
                                      color: Colors.lightBlue[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'from CathsApp',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Share button
            if (!isSharing)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sharePassage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.lightBlue.withOpacity(0.3),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Share Passage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (isSharing)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: CircularProgressIndicator(
                  color: Colors.lightBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
