# Flutter Popup Notification

A beautiful, WhatsApp-style popup notification package for Flutter that can be triggered from anywhere in your app without requiring BuildContext.

![Package Banner](https://via.placeholder.com/1200x300)

## Features

- 🎯 Context-free notifications - show popups from anywhere
- 🔄 Auto-dismissing with customizable duration
- 👆 Swipe left/right to dismiss
- 🖼️ Support for avatar images
- 🎨 Beautiful animations using animate_do
- 🔥 GoRouter compatible
- 🧹 Auto-clears existing popups
- 📱 Safe area (notch) aware
- 🎬 Tap handling for navigation
- 📝 Clean, minimalist design

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  popup_notification:
    git:
      url: https://github.com/yourusername/popup_notification.git
```

## Quick Start

### 1. Initialize

In your `main.dart` file where you configure GoRouter:

```dart
final router = GoRouter(
  // your routes configuration
);

void main() {
  // Initialize popup notification with your router
  PopupNotification.init(router);
  
  runApp(MyApp(router: router));
}
```

### 2. Show a Popup

Show a popup from anywhere in your app:

```dart
PopupNotification.show(
  title: "New Message",
  message: "Hey, how are you?",
  avatarUrl: "https://example.com/avatar.jpg",
  onTap: () {
    // Handle tap action
  },
  duration: Duration(seconds: 3),
);
```

## Examples

### Basic Notification
```dart
PopupNotification.show(
  title: "Simple Notification",
  message: "This is a basic notification",
);
```

### With Avatar and Navigation
```dart
PopupNotification.show(
  title: "John Doe",
  message: "Hey! Check out this new feature...",
  avatarUrl: "https://example.com/john.jpg",
  onTap: () => router.push('/chat/john-doe'),
);
```

### Custom Duration
```dart
PopupNotification.show(
  title: "Quick Alert",
  message: "This will disappear in 1 second",
  duration: Duration(seconds: 1),
);
```

## Customization

### Styling

The popup uses Google Fonts' Inter font family by default. You can modify the styling by editing the `_PopupNotificationWidget` class:

```dart
Text(
  title,
  style: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
),
```

### Animation

The popup uses the `animate_do` package for the entrance animation. You can modify the animation by adjusting the `FadeInDown` widget parameters:

```dart
FadeInDown(
  duration: const Duration(milliseconds: 300),
  child: // ... your widget
),
```

## Requirements

- Flutter: >=3.0.0
- go_router: ^14.0.0
- google_fonts: ^6.0.0
- animate_do: ^3.0.0

## Contributing

Contributions are welcome! If you find a bug or want to add a new feature:

1. Open an issue
2. Fork the repo
3. Create a new branch (`git checkout -b feature/amazing-feature`)
4. Make your changes
5. Commit (`git commit -m 'Add amazing feature'`)
6. Push (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you like this package, consider giving it a star ⭐ on GitHub!

For bugs or feature requests, open an issue on the [GitHub repository](https://github.com/yourusername/popup_notification/issues).

## Credits

Created with ❤️ by [Your Name]