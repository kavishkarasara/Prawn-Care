import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:prawn__farm/models/notification_item.dart';
import 'package:prawn__farm/screens/get_start_screen.dart';
import 'package:prawn__farm/screens/workers/feeding_schedule_page.dart';
import 'package:prawn__farm/screens/workers/orders_screen.dart';
import 'package:prawn__farm/screens/workers/special_note.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/services/location_service.dart';
import 'package:prawn__farm/services/push_notification_service.dart';
import 'package:prawn__farm/services/task_service.dart';
import 'package:prawn__farm/services/weather_service.dart';
import 'package:prawn__farm/services/worker_notification.dart';
import 'package:prawn__farm/widgets/common/metric_card.dart';
import 'package:prawn__farm/widgets/location_dialog.dart';
import 'package:prawn__farm/widgets/notification_dialog.dart';
import 'package:prawn__farm/widgets/pond_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrawnCareHomePage extends StatefulWidget {
  const PrawnCareHomePage({super.key});

  @override
  State<PrawnCareHomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<PrawnCareHomePage> {
  String temperature = '__°C';
  String humidity = '__%';
  bool isWeatherLoading = false;
  String locationName = 'Getting location...';
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLocationLoading = true;
  List<NotificationItem> notifications = [];
  int unreadCount = 0;
  int specialNotesCount = 0;
  bool isSpecialNotesLoading = false;

  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  final WorkerNotificationManager _workerNotificationManager =
      WorkerNotificationManager.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndWeather();
    _initializeNotifications();
    _loadSpecialNotesCount();
  }

  Future<void> _getCurrentLocationAndWeather() async {
    setState(() {
      isLocationLoading = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _handleLocationError('Unable to get current location');
        return;
      }
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String locality = placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            'Unknown location';

        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          locationName = locality;
        });

        _getWeatherData();
      }
    } catch (e) {
      _handleLocationError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLocationLoading = false;
        });
      }
    }
  }

  void _handleLocationError(String error) {
    debugPrint("Location error: $error");
    if (mounted) {
      setState(() {
        locationName = 'Location unavailable';
        isLocationLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationDialog(
          onRefresh: () {
            Navigator.pop(context);
            _getCurrentLocationAndWeather();
          },
          onSelectPredefined: (name, lat, lon) {
            setState(() {
              locationName = name;
              latitude = lat;
              longitude = lon;
            });
            Navigator.pop(context);
            _getWeatherData();
          },
        );
      },
    );
  }

  Future<void> _getWeatherData() async {
    if (!mounted) return;

    setState(() {
      isWeatherLoading = true;
    });

    try {
      final weather = await _weatherService.getWeather(latitude, longitude);
      if (mounted) {
        setState(() {
          temperature = "${weather.temperature.toStringAsFixed(1)}°C";
          humidity = "${weather.humidity}%";
        });
      }
    } catch (e) {
      _handleWeatherError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isWeatherLoading = false;
        });
      }
    }
  }

  void _handleWeatherError(String error) {
    debugPrint("Weather error: $error");
    if (mounted) {
      setState(() {
        temperature = "Error";
        humidity = "Error";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      final authService = AuthService();
      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        await _pushNotificationService.initialize();
        await _pushNotificationService.setCurrentUser(userId, 'worker');
        await _loadNotifications();
      }
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final workerNotifications =
          await _workerNotificationManager.getNotifications();
      final notificationItems = workerNotifications
          .map((n) => _convertToNotificationItem(n))
          .toList();
      final count = await _pushNotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          notifications = notificationItems;
          unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  NotificationItem _convertToNotificationItem(WorkerNotification notification) {
    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.temperature:
        icon = Icons.thermostat;
        iconColor = Colors.orange;
        break;
      case NotificationType.humidity:
        icon = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case NotificationType.feeding:
        icon = Icons.restaurant;
        iconColor = Colors.green;
        break;
      case NotificationType.order:
        icon = Icons.shopping_cart;
        iconColor = Colors.purple;
        break;
      case NotificationType.alert:
        icon = Icons.warning;
        iconColor = Colors.red;
        break;
      case NotificationType.task:
        icon = Icons.check_circle;
        iconColor = Colors.teal;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }
    return NotificationItem(
      icon: icon,
      iconColor: iconColor,
      title: notification.title,
      message: notification.message,
      time: _formatTime(notification.timestamp),
    );
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _showNotificationDialog() async {
    await _workerNotificationManager.refreshReminders();
    await _loadNotifications();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationDialog(
          onMarkAllAsRead: () async {
            await _pushNotificationService.markAllAsRead();
            await _loadNotifications();
          },
          notifications: notifications,
          unreadCount: unreadCount,
        );
      },
    );
  }

  Future<void> _loadSpecialNotesCount() async {
    setState(() {
      isSpecialNotesLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          specialNotesCount = 0;
          isSpecialNotesLoading = false;
        });
        return;
      }

      final TaskApiService _taskService = TaskApiService();
      final tasks = await _taskService.fetchTasks(token);

      // Count tasks with status 'Pending'
      int pendingCount = 0;
      for (var task in tasks) {
        if (task.status.toLowerCase() == 'pending') {
          pendingCount++;
        }
      }

      if (mounted) {
        setState(() {
          specialNotesCount = pendingCount;
          isSpecialNotesLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading special notes count: $e");
      if (mounted) {
        setState(() {
          specialNotesCount = 0;
          isSpecialNotesLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _getCurrentLocationAndWeather();
    await _loadNotifications();
    await _loadSpecialNotesCount();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    // ignore: unused_local_variable
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    // ignore: unused_local_variable
    final isLargeScreen = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: isSmallScreen ? 16 : 24,
                    right: isSmallScreen ? 16 : 24,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PrawnCare',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 24 : 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: _showLocationDialog,
                                  child: Row(
                                    children: [
                                      isLocationLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Flexible(
                                              child: Text(
                                                locationName,
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize:
                                                      isSmallScreen ? 14 : 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.arrow_drop_down,
                                          color: Colors.white70, size: 20),
                                    ],
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'New Alerts: $unreadCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 12 : 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              WorkerNotificationService.buildNotificationButton(
                                hasNotification: unreadCount > 0,
                                onTap: _showNotificationDialog,
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _showSignOutDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Weather Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin:
                                EdgeInsets.only(right: isSmallScreen ? 8 : 10),
                            child: MetricCard(
                              imagePath: 'assets/images/temperature.png',
                              useOriginalColors: true,
                              iconBgColor: Colors.orange.shade50,
                              value:
                                  isWeatherLoading ? 'Loading...' : temperature,
                              label: 'Temperature',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin:
                                EdgeInsets.only(left: isSmallScreen ? 8 : 10),
                            child: MetricCard(
                              imagePath: 'assets/images/humidity.png',
                              useOriginalColors: true,
                              iconBgColor: Colors.blue.shade50,
                              value: isWeatherLoading ? 'Loading...' : humidity,
                              label: 'Humidity',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 40),

                    // Single Column Layout for all cards
                    Column(
                      children: [
                        // Ponds Condition Card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PondDetailsScreen(),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: isSmallScreen ? 100 : 120,
                            margin: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 4 : 6),
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 45),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/images/pond_con.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Ponds Condition',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Special Notes Card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SpecialNotePage(),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: isSmallScreen ? 100 : 120,
                            margin: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 4 : 6),
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          Icons.analytics_rounded,
                                          size: 60,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (specialNotesCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              specialNotesCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      'Special Notes',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Feeding Schedule Card
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 4 : 6),
                          child: FeatureCard(
                            imagePath: 'assets/images/feeding.png',
                            useOriginalColors: true,
                            iconBgColor: Colors.white,
                            title: 'Feeding Schedule',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FeedingSchedulePage(),
                                ),
                              );
                            },
                          ),
                        ),
                        // Orders Card
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 4 : 6),
                          child: FeatureCard(
                            imagePath: 'assets/images/order.png',
                            useOriginalColors: true,
                            iconBgColor: Colors.white,
                            title: 'Orders',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrdersPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced FeatureCard widget with modern design
class FeatureCard extends StatelessWidget {
  final String imagePath;
  final bool useOriginalColors;
  final Color iconBgColor;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    required this.imagePath,
    required this.useOriginalColors,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Determine gradient based on title
    LinearGradient gradient;
    Color shadowColor;
    if (title == 'Feeding Schedule') {
      gradient = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      shadowColor = const Color(0xFFF59E0B).withOpacity(0.3);
    } else if (title == 'Orders') {
      gradient = const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      shadowColor = const Color(0xFF8B5CF6).withOpacity(0.3);
    } else {
      gradient = const LinearGradient(
        colors: [Colors.white, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      shadowColor = Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: isSmallScreen ? 100 : 120,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: (title == 'Feeding Schedule' || title == 'Orders')
                        ? Colors.white
                        : Colors.grey.shade800,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
