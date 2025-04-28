import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hr_pulse_app/screens/home_screen.dart';
import 'package:hr_pulse_app/screens/login_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hr_pulse_app/service/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userId = prefs.getString('userId');
  String? role = prefs.getString('role');

  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId, role: role));
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling background message: ${message.messageId}');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn, this.userId, this.role});

  final bool isLoggedIn;
  final String? userId;
  final String? role;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home:
          isLoggedIn ? HomeScreen(userId: userId!, role: role!) : LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
