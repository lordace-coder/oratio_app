# oratio_app

A new Flutter project.

`
<!-- Provide required visibility configuration for API level 30 and above -->
<queries>
  <!-- If your app checks for SMS support -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="sms" />
  </intent>
  <!-- If your app checks for call support -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="tel" />
  </intent>
  <!-- If your application checks for inAppBrowserView launch mode support -->
  <intent>
    <action android:name="android.support.customtabs.action.CustomTabsService" />
  </intent>
</queries>
`

<!-- ios -->
'<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
  <string>tel</string>
</array>
`

`
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'smith@example.com',
    query: encodeQueryParameters(<String, String>{
      'subject': 'Example Subject & Symbols are allowed!',
    }),
  );

  launchUrl(emailLaunchUri);
`




# PocketBase Server with OneSignal Notifications

## OneSignal Integration Guide

### 1. OneSignal Setup

1. Create an account at [OneSignal](https://onesignal.com).
2. Create a new app in the OneSignal dashboard.
3. Configure your app with these settings:
   - **App ID**: YOUR_APP_ID
   - **REST API Key**: YOUR_REST_API_KEY

### 2. Flutter App Integration

#### 2.1. Add OneSignal Package

Add the OneSignal package to your `pubspec.yaml`:

```yaml
dependencies:
  onesignal_flutter: ^5.0.0
```

#### 2.2. Initialize OneSignal

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';

void initOneSignal() {
  OneSignal.shared.setAppId("YOUR_APP_ID");

  // Enable debug logs
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  // Handle notification opened
  OneSignal.shared.setNotificationOpenedHandler((openedResult) {
    print("Opened notification: ${openedResult.notification.body}");
  });

  // Handle notification received while app is running
  OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
    print("Received notification: ${event.notification.body}");
  });
}
```

#### 2.3. Set External User ID

```dart
void setExternalUserId(String userId) async {
  await OneSignal.login(userId);
}
```

FOR WEBSOCKET ONLINE

```dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebSocketChannel? channel;
  TextEditingController controller = TextEditingController();
  String userId = "your_user_id"; // Replace with the actual user ID

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8090/ws?uid=$userId'),
    );

    channel!.stream.listen(
      (message) {
        print('Received: $message');
      },
      onDone: () {
        print('WebSocket closed');
        setUserActiveStatus(false);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );

    setUserActiveStatus(true);
  }

  void setUserActiveStatus(bool active) {
    // Implement the logic to update the user's active status in your app
    print('User active status: $active');
  }

  @override
  void dispose() {
    channel?.sink.close(status.goingAway);
    setUserActiveStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Send a message'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (channel != null) {
                  channel!.sink.add(controller.text);
                }
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
```
