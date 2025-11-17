import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prawn__farm/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:prawn__farm/utils/constants.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription? _notificationSubscription;
  IO.Socket? _socket;
  String? _currentUserId;
  String? _userType;

  // Stream for order updates
  final StreamController<Map<String, dynamic>> _orderUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get orderUpdateStream =>
      _orderUpdateController.stream;

  /// Initialize push notification service
  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'prawn_farm_channel',
        'Prawn Farm Notifications',
        description: 'Notifications for Prawn Farm app',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Request permissions
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Load user data
    await _loadUserData();
  }

  /// Set current user for notifications
  Future<void> setCurrentUser(String userId, String userType) async {
    _currentUserId = userId;
    _userType = userType;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_user_id', userId);
    await prefs.setString('notification_user_type', userType);

    // Start listening for notifications
    await _startListeningForNotifications();
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('notification_user_id');
    _userType = prefs.getString('notification_user_type');

    if (_currentUserId != null && _userType != null) {
      await _startListeningForNotifications();
    }
  }

  /// Start listening for notifications from Supabase or Socket.IO
  Future<void> _startListeningForNotifications() async {
    if (_currentUserId == null || _userType == null) return;

    // Cancel existing subscription
    await _notificationSubscription?.cancel();

    // Listen for notifications based on user type
    if (_userType == 'supplier') {
      _notificationSubscription =
          SupabaseService.getNotificationsStream(_currentUserId!).listen(
        _handleNotification,
        onError: (error) {
          debugPrint('Error listening to supplier notifications: $error');
        },
      );
    } else if (_userType == 'worker') {
      // For workers, listen to worker-specific notifications
      _notificationSubscription = SupabaseService.streamTable(
        table: 'worker_notifications',
        conditions: {'worker_id': _currentUserId},
        orderBy: 'created_at',
        ascending: false,
      ).listen(
        _handleNotification,
        onError: (error) {
          debugPrint('Error listening to worker notifications: $error');
        },
      );
    } else if (_userType == 'customer') {
      // For customers, use Socket.IO for real-time notifications
      await _connectToSocketIO();
    }
  }

  /// Handle incoming notification
  void _handleNotification(List<Map<String, dynamic>> notifications) {
    for (final notification in notifications) {
      final isRead = notification['is_read'] ?? false;
      if (!isRead) {
        _showLocalNotification(notification);
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(Map<String, dynamic> notification) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prawn_farm_channel',
      'Prawn Farm Notifications',
      channelDescription: 'Notifications for Prawn Farm app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = notification['title'] ?? 'New Notification';
    final body = notification['message'] ?? 'You have a new notification';
    final id =
        notification['id']?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: jsonEncode(notification),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final notification =
            jsonDecode(response.payload!) as Map<String, dynamic>;
        final notificationId = notification['id'];

        // Mark notification as read
        if (notificationId != null && _currentUserId != null) {
          if (_userType == 'supplier') {
            SupabaseService.markNotificationAsRead(notificationId.toString());
          } else if (_userType == 'worker') {
            // Mark worker notification as read
            SupabaseService.update(
              table: 'worker_notifications',
              data: {'is_read': true},
              conditions: {'id': notificationId},
            );
          } else if (_userType == 'customer') {
            // Mark customer notification as read
            SupabaseService.update(
              table: 'customer_notifications',
              data: {'is_read': true},
              conditions: {'id': notificationId},
            );
          }
        }

        // Navigate to appropriate screen based on notification type
        _navigateToNotificationScreen(notification);
      } catch (e) {
        debugPrint('Error handling notification tap: $e');
      }
    }
  }

  /// Navigate to appropriate screen based on notification
  void _navigateToNotificationScreen(Map<String, dynamic> notification) {
    final type = notification['type'];

    // This would typically use a navigation service or global navigator key
    // For now, we'll just print the navigation intent
    debugPrint('Navigate to screen for notification type: $type');

    // For order updates, navigate to order tracking screen
    if (type == 'order_update') {
      debugPrint(
          'Navigate to Order Tracking Screen for order: ${notification['orderId']}');
    }
  }

  /// Send test notification (for development)
  Future<void> sendTestNotification({
    required String title,
    required String message,
    String? type,
  }) async {
    if (_currentUserId == null || _userType == null) return;

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'type': type ?? 'test',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _showLocalNotification(notification);
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    if (_currentUserId == null || _userType == null) return 0;

    try {
      if (_userType == 'supplier') {
        return await SupabaseService.getUnreadNotificationCount(
            _currentUserId!);
      } else if (_userType == 'worker') {
        return await SupabaseService.count(
          table: 'worker_notifications',
          conditions: {'worker_id': _currentUserId, 'is_read': false},
        );
      } else if (_userType == 'customer') {
        return await SupabaseService.count(
          table: 'customer_notifications',
          conditions: {'customer_id': _currentUserId, 'is_read': false},
        );
      }
    } catch (e) {
      debugPrint('Error getting unread count: $e');
    }

    return 0;
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null || _userType == null) return;

    try {
      if (_userType == 'supplier') {
        await SupabaseService.markAllNotificationsAsRead(_currentUserId!);
      } else if (_userType == 'worker') {
        await SupabaseService.update(
          table: 'worker_notifications',
          data: {'is_read': true},
          conditions: {'worker_id': _currentUserId, 'is_read': false},
        );
      } else if (_userType == 'customer') {
        await SupabaseService.update(
          table: 'customer_notifications',
          data: {'is_read': true},
          conditions: {'customer_id': _currentUserId, 'is_read': false},
        );
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  /// Clear user data (on logout)
  Future<void> clearUserData() async {
    _currentUserId = null;
    _userType = null;

    // Cancel subscription
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;

    // Disconnect socket
    _socket?.disconnect();
    _socket = null;

    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_user_id');
    await prefs.remove('notification_user_type');
  }

  /// Connect to Socket.IO server for customer notifications
  Future<void> _connectToSocketIO() async {
    if (_currentUserId == null) return;

    debugPrint(
        'Attempting to connect to Socket.IO server for user: $_currentUserId');

    // Disconnect existing socket
    _socket?.disconnect();

    // Connect to Socket.IO server
    _socket = IO.io(BACKEND_BASE_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      debugPrint('Connected to Socket.IO server');
      // Join customer room
      _socket!.emit('join', {'userId': _currentUserId, 'userType': 'customer'});
      debugPrint(
          'Emitted join event with userId: $_currentUserId, userType: customer');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Disconnected from Socket.IO server');
    });

    _socket!.onConnectError((error) {
      debugPrint('Socket.IO connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('Socket.IO error: $error');
    });

    // Listen for task updates
    _socket!.on('task_updated', (data) {
      debugPrint('Received task update: $data');
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': 'Task Update',
        'message': data['message'] ?? 'A task has been updated',
        'type': 'task_update',
        'task_id': data['task_id'],
        'status': data['status'],
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };
      _showLocalNotification(notification);
    });

    // Listen for order status updates
    _socket!.on('order-status-update', (data) {
      debugPrint('Received order-status-update event: $data');

      // Notifications are targeted via Socket.IO rooms, so no need to check customer_email

      // Show snackbar for in-app notification
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          final context = WidgetsBinding.instance!.renderViewElement;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Order ${data['order_id']} status updated to ${data['status']}'),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.blue,
              ),
            );
          }
        });
      }

      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': 'Order Status Updated',
        'message':
            'Your order #${data['order_id']} status has been updated to: ${data['status']}. Thank you for your business!',
        'type': 'order_update',
        'orderId': data['order_id'],
        'status': data['status'],
        'customer_id': data['customer_id'],
        'is_read': false,
        'created_at_notification': DateTime.now().toIso8601String(),
      };
      _showLocalNotification(notification);

      // Emit to stream for UI updates
      _orderUpdateController.add(data);
    });

    // Listen for any event to debug
    _socket!.onAny((event, data) {
      debugPrint('Received any event: $event with data: $data');
    });

    _socket!.connect();
  }

  /// Dispose resources
  void dispose() {
    _notificationSubscription?.cancel();
    _socket?.disconnect();
    _orderUpdateController.close();
  }
}
