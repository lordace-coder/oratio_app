import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopupNotification {
  static late BuildContext _context;
  static OverlayEntry? _currentEntry;
  static bool _isVisible = false;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static void show({
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color iconBackgroundColor = Colors.green,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    hide();

    _isVisible = true;
    _currentEntry = OverlayEntry(
      builder: (context) => _PopupNotificationWidget(
        title: title,
        message: message,
        icon: icon,
        iconBackgroundColor: iconBackgroundColor,
        onTap: onTap,
        onDismiss: () => hide(),
      ),
    );

    Overlay.of(_context).insert(_currentEntry!);

    Future.delayed(duration, () {
      if (_isVisible) {
        hide();
      }
    });
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isVisible = false;
  }
}

class _PopupNotificationWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _PopupNotificationWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconBackgroundColor,
    this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (_) => onDismiss(),
          direction: DismissDirection.horizontal,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          message,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "Now",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
