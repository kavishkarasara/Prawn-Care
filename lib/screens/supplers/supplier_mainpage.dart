import 'package:flutter/material.dart';
import 'package:prawn__farm/screens/supplers/request_orders_screen.dart';
import 'package:prawn__farm/widgets/menu_card.dart';
import 'package:prawn__farm/widgets/supplier_main_header.dart';
import 'package:prawn__farm/widgets/notification_dialog.dart';
import 'package:prawn__farm/services/weather_service.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/screens/get_start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierMainpage extends StatefulWidget {
  const SupplierMainpage({super.key});

  @override
  State<SupplierMainpage> createState() => _SupplierMainpageState();
}

class _SupplierMainpageState extends State<SupplierMainpage> {
  String locationName = 'Loading...';
  String temperature = 'Loading...';
  String humidity = 'Loading...';
  int unreadNotificationCount = 4;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      // For demonstration, using fixed coordinates; replace with actual location fetching logic if needed
      final weather = await WeatherService().getWeather(0.0, 0.0);
      setState(() {
        locationName = 'Current Location';
        temperature = "${weather.temperature.toStringAsFixed(1)}°C";
        humidity = "${weather.humidity}%";
      });
    } catch (e) {
      setState(() {
        locationName = 'Unknown';
        temperature = 'N/A';
        humidity = 'N/A';
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      unreadNotificationCount = 0;
    });
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationDialog(
          onMarkAllAsRead: _markAllAsRead,
          notifications: [], // Dummy list since hardcoded in dialog
          unreadCount: unreadNotificationCount,
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      final authService = AuthService();
      await authService.signOut();

      // Clear user type from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userType');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GetStartScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SupplierMainHeader(
              unreadNotificationCount: unreadNotificationCount,
              onNotificationsPressed: _showNotificationDialog,
              onSignOutPressed: _showSignOutDialog,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MenuCard(
                    icon: Icons.inventory_2,
                    iconColor: Colors.blue,
                    backgroundColor: const Color(0xFFE8E4FF),
                    title: 'Requested Orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestORdersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
