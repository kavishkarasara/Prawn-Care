/// This file contains the CustomerMainpage widget, which serves as the main dashboard for customers.
/// It provides access to order placement, order history, order tracking, and notifications.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prawn__farm/screens/customers/order_track.dart';
import 'package:prawn__farm/models/notification_item.dart';
import 'package:prawn__farm/screens/customers/order_history.dart';
import 'package:prawn__farm/screens/customers/place_order_screen.dart';
import 'package:prawn__farm/widgets/customer_main_widgets.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/services/push_notification_service.dart';
import 'package:prawn__farm/screens/get_start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The main page for customers, displaying menu options for ordering, tracking, and history.
/// Also handles notifications and user sign-out functionality.
class CustomerMainpage extends StatefulWidget {
  /// Constructor for CustomerMainpage.
  const CustomerMainpage({super.key});

  @override
  State<CustomerMainpage> createState() => _CustomerMainpageState();
}

class _CustomerMainpageState extends State<CustomerMainpage> {
  List<NotificationItem> notifications = [];
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  StreamSubscription? _orderUpdateSubscription;

  int get unreadNotificationCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToOrderUpdates();
  }

  @override
  void dispose() {
    _orderUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      final authService = AuthService();
      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        await _pushNotificationService.initialize();
        await _pushNotificationService.setCurrentUser(userId, 'customer');
      }
    } catch (e) {
      debugPrint("Error initializing customer notifications: $e");
    }
  }

  void _listenToOrderUpdates() {
    _orderUpdateSubscription =
        _pushNotificationService.orderUpdateStream.listen((data) {
      // Add notification to the list
      final notification = NotificationItem(
        icon: Icons.local_shipping,
        iconColor: Colors.blue,
        title: 'Order Status Updated',
        message:
            'Your order #${data['order_id']} status has been updated to: ${data['status']}. Thank you for your business!',
        time: DateTime.now().toString().split(' ')[0], // Simple date format
        isRead: false,
      );

      setState(() {
        notifications.insert(0, notification); // Add to top of list
      });

      // Show snackbar for in-app notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order #${data['order_id']} status updated to ${data['status']}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.notifications, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: notifications.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]
                  : notifications
                      .map((notification) => Column(
                            children: [
                              NotificationListItem(notification: notification),
                              if (notification != notifications.last)
                                const Divider(),
                            ],
                          ))
                      .toList(),
            ),
          ),
          actions: [
            if (unreadNotificationCount > 0)
              TextButton(
                onPressed: () {
                  _markAllAsRead();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Mark All as Read',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/prawncare.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 15,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 28,
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                          onPressed: _showSignOutDialog,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              iconSize: 28,
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.amber,
                              ),
                              onPressed: _showNotificationDialog,
                            ),
                            if (unreadNotificationCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadNotificationCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MenuCard(
                    icon: Icons.add_shopping_cart,
                    iconColor: const Color(0xFF6C63FF),
                    backgroundColor: const Color(0xFFE3F2FD),
                    title: 'Place Order',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlaceOrderScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  MenuCard(
                    icon: Icons.history,
                    iconColor: Colors.orange,
                    backgroundColor: const Color(0xFFFFF3E0),
                    title: 'Order History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  MenuCard(
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    backgroundColor: const Color(0xFFE8F5E8),
                    title: 'Order Tracking',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderTrackingScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
