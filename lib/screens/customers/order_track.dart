/// This file contains the OrderTrackingScreen widget, which displays real-time order tracking.
/// It shows order status updates, timelines, and listens to push notifications for order changes.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prawn__farm/models/order.dart';
import 'package:prawn__farm/services/api_service.dart';
import 'package:prawn__farm/services/push_notification_service.dart';

/// A screen that displays real-time order tracking with visual timelines.
/// Shows order progress from approval to delivery and updates via push notifications.
class OrderTrackingScreen extends StatefulWidget {
  /// Constructor for OrderTrackingScreen.
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<Order> orders = [];
  bool isLoading = true;
  StreamSubscription? _orderUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _listenToOrderUpdates();
  }

  @override
  void dispose() {
    _orderUpdateSubscription?.cancel();
    super.dispose();
  }

  void _listenToOrderUpdates() {
    _orderUpdateSubscription =
        PushNotificationService().orderUpdateStream.listen((data) {
      // Refresh orders when an update is received
      _fetchOrders();
      // Show snackbar for in-app notification when app is in foreground
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order #${data['order_id']} status updated to ${data['status']}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedOrders = await ApiService().getCustomerOrders();
      setState(() {
        orders = fetchedOrders
            .where((order) => order.approvedOrRejected != 'Rejected')
            .toList();
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  List<Widget> _buildTimelineWidgets(
      List<Map<String, dynamic>> timelineItems, String status) {
    List<Widget> widgets = [];
    for (int i = 0; i < timelineItems.length; i++) {
      widgets.add(_TimelineItem(
        icon: timelineItems[i]['icon'],
        title: timelineItems[i]['title'],
        isCompleted: timelineItems[i]['isCompleted'],
        isActive: timelineItems[i]['isActive'],
        isFirst: i == 0,
        isLast: i == timelineItems.length - 1,
        status: status,
      ));
    }
    return widgets;
  }

  List<Map<String, dynamic>> _getTimelineItems(
      String status, String? approvedOrRejected) {
    final allItems = [
      {
        'icon': Icons.check_circle,
        'title': 'Approved',
        'isCompleted': false,
        'isActive': false
      },
      {
        'icon': Icons.inventory,
        'title': 'Order Processing',
        'isCompleted': false,
        'isActive': false
      },
      {
        'icon': Icons.local_shipping,
        'title': 'Hand Over to Warehouse',
        'isCompleted': false,
        'isActive': false
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'Hand Over to Delivery',
        'isCompleted': false,
        'isActive': false
      },
    ];

    // Adjust based on approvedOrRejected for Approved stage
    if (approvedOrRejected == 'Approved') {
      allItems[0]['isCompleted'] = true;
    }

    // Adjust based on status for other stages
    if (status == 'Processing') {
      allItems[1]['isActive'] = true;
    } else if (status == 'delivered') {
      allItems[0]['isCompleted'] = true;
      allItems[1]['isCompleted'] = true;
      allItems[2]['isActive'] = true;
    } else if (status == 'Complete order' || status == 'Completed') {
      allItems[1]['isCompleted'] = true;
      allItems[2]['isCompleted'] = true;
      allItems[3]['isCompleted'] = true;
    }

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
        ),
        child: Column(
          children: [
            // Custom header container
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(22.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(22.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => _fetchOrders(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: const Text(
                        'Order Tracking',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : orders.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No orders found',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    final timelineItems = _getTimelineItems(
                                        order.status ?? 'Pending',
                                        order.approvedOrRejected);
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Order ID: ${order.orderId ?? 'N/A'}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.indigo,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Product: ${order.product ?? 'Unknown'}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.indigo,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Quantity',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Price',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Placed Date',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${order.quantity} Kg',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Rs. ${order.price?.toStringAsFixed(2)}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            '${order.createdAt?.toString().split(' ')[0]}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: _buildTimelineWidgets(
                                                timelineItems,
                                                order.status ?? 'Pending'),
                                          ),
                                        ),
                                        const Divider(height: 30),
                                      ],
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isCompleted;
  final bool isActive;
  final bool isFirst;
  final bool isLast;
  final String status;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.isCompleted,
    required this.isActive,
    required this.isFirst,
    required this.isLast,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      // Specific color changes based on status and title
      if ((status.toLowerCase() == 'processing' ||
              status.toLowerCase() == 'delivered') &&
          title == 'Order Processing') {
        return Colors.yellow;
      }
      if (status.toLowerCase() == 'delivered' &&
          title == 'Hand Over to Warehouse') {
        return Colors.blue;
      }
      if (status.toLowerCase() == 'complete' &&
          title == 'Hand Over to Delivery') {
        return Colors.orange;
      }

      // Default logic
      if (isCompleted) {
        if (title == 'Order Processing') return Colors.yellow;
        if (title == 'Hand Over to Warehouse')
          return const Color.fromARGB(255, 68, 58, 249);
        if (title == 'Hand Over to Delivery') return Colors.orange;
        return Colors.green;
      }
      if (isActive) return const Color.fromARGB(255, 68, 58, 249);
      return Colors.grey;
    }

    return Row(
      children: [
        SizedBox(
          width: 50,
        ),
        // Timeline indicator
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: getColor(),
              ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: getColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: getColor().withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: isCompleted ? getColor() : Colors.grey[300],
              ),
          ],
        ),

        const SizedBox(width: 50),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: (status.toLowerCase() == 'processing' &&
                          title == 'Order Processing')
                      ? Colors.yellow
                      : (isActive ? getColor() : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
