/// This file is the entry point of the Flutter application.
/// It initializes the app, sets up local notifications, initializes Supabase,
/// checks user authentication, and determines the first screen to display based on user role.

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prawn__farm/screens/customers/customer_mainpage.dart';
import 'package:prawn__farm/screens/get_start_screen.dart';
import 'package:prawn__farm/screens/supplers/supplier_mainpage.dart';
import 'package:prawn__farm/screens/workers/prawn_care_home_page.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/services/supabase_service.dart';

/// The main function initializes the Flutter app, sets up notifications,
/// initializes Supabase, checks user authentication, and runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'worker_notifications_channel',
    'Worker Notifications',
    description: 'Notifications for workers',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  // Request notification permissions for Android
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {}

  await SupabaseService.initialize(
    url: 'https://tojqxdziducxpnhydaby.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvanF4ZHppZHVjeHBuaHlkYWJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzMwNTIsImV4cCI6MjA3MjY0OTA1Mn0.s_0e2fTpqQxmzkEg9cHl6UAOT5aZoCLgbEUpPBrZc3g',
  );

  // Check if user is still authenticated and get their role
  final authService = AuthService();
  Widget firstPage = const GetStartScreen();

  if (authService.isSignedIn) {
    try {
      final profile = await authService.getCurrentUserProfile();
      if (profile != null) {
        final role = profile['role'] as String?;
        if (role == "customer") {
          firstPage = const CustomerMainpage();
        } else if (role == "supplier") {
          firstPage = const SupplierMainpage();
        } else if (role == "worker") {
          firstPage = const PrawnCareHomePage();
        }
      }
    } catch (e) {
      // If there's an error getting profile, show get started screen
      firstPage = const GetStartScreen();
    }
  }

  runApp(MyApp(firstPage: firstPage));
}

/// The main application widget that sets up the MaterialApp with theme and home page.
class MyApp extends StatelessWidget {
  /// The first page to display based on user authentication and role.
  final Widget firstPage;

  /// Constructor for MyApp.
  const MyApp({super.key, required this.firstPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: firstPage,
    );
  }
}
