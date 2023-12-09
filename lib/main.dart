import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app_notification/provider/chat_provider.dart';
import 'package:chat_app_notification/provider/init_user_provider.dart';
import 'package:chat_app_notification/provider/login_provider.dart';
import 'package:chat_app_notification/provider/profile_provider.dart';
import 'package:chat_app_notification/provider/register_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if notification permissions are granted
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Permissions are granted, proceed with initialization
    var token = await FirebaseMessaging.instance.getToken();
    print("Fcm Token : $token");

    // Initialize Awesome Notifications
    AwesomeNotifications().initialize(
      null, // set the icon to `null` if you want to use the default app icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
        ),
      ],
    );

    //foreground fcm
    FirebaseMessaging.onMessage.listen((event) {
      print("on message");
      print(event.data.toString());
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: 'basic_channel',
          title: event.notification?.title ?? 'Notification',
          body: event.notification?.body ?? 'This is an awesome notification!',
        ),
      );
    });

    //when click on notification to open app
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("on message opened app");
      print(event.data.toString());
    });

    // background fcm
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    //Firebase FireStore.instance.disableNetwork();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => InitUserProvider()),
          ChangeNotifierProvider(create: (context) => RegisterProvider()),
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } else {
    // Handle the case where notifications are not allowed
    print("Notifications are disabled");
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => InitUserProvider()),
          ChangeNotifierProvider(create: (context) => RegisterProvider()),
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ],
        child: const MyApp(),
      ),
    );
    // You might want to inform the user or request permission again
  }
}
