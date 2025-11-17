/// This file contains the OrderHistoryScreen widget, which displays a customer's order history.
/// It allows filtering orders by status and shows detailed information for each order.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order.dart';
import '../../../services/api_service.dart';

/// A screen that displays the customer's order history with filtering capabilities.
/// Shows order details including ID, product, date, status, and other relevant information.
class OrderHistoryScreen extends StatefulWidget {
  /// Constructor for OrderHistoryScreen.
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedOrders = await ApiService().getCustomerOrders();
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      // Handle error, e.g., show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'New',
    'Processing',
    'Finished',
    'Delivered'
  ];

  List<Order> get filteredOrders {
    if (_selectedFilter == 'All') {
      return orders;
    }
    return orders
        .where((order) => getDisplayStatus(order) == _selectedFilter)
        .toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Orders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _filterOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedFilter,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFilter = value ?? 'All';
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String getDisplayStatus(Order order) {
    switch (order.status?.toLowerCase()) {
      case 'new':
        return 'New';
      case 'processing':
        return 'Processing';
      case 'finished':
      case 'completed':
        return 'Finished';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Processing';
    }
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
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with filter
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Orders History',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _showFilterDialog,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF4F46E5)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.filter_list,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _selectedFilter,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // Orders count
                              Text(
                                '${filteredOrders.length} ${filteredOrders.length == 1 ? 'Order' : 'Orders'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Orders list
                              Expanded(
                                child: filteredOrders.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.receipt_long,
                                              size: 80,
                                              color: Color(0xFF6366F1),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'No orders found',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Your order history will appear here.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: filteredOrders.length,
                                        itemBuilder: (context, index) {
                                          return _OrderCard(
                                              order: filteredOrders[index]);
                                        },
                                      ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  String getDisplayStatus() {
    switch (order.status?.toLowerCase()) {
      case 'new':
        return 'New';
      case 'processing':
        return 'Processing';
      case 'finished':
      case 'completed':
        return 'Finished';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Processing';
    }
  }

  Color _getStatusColor() {
    switch (getDisplayStatus()) {
      case 'New':
        return Colors.blue.shade600;
      case 'Processing':
        return Color(0xFF6C63FF);
      case 'Finished':
        return Colors.orange.shade600;
      case 'Delivered':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add tap animation or navigation if needed
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _OrderRow(
              icon: Icons.confirmation_number,
              label: 'ORDER ID',
              value: order.orderId?.toString() ?? '0',
            ),
            _OrderRow(
              icon: Icons.inventory,
              label: 'PRODUCT',
              value: order.product ?? 'N/A',
            ),
            _OrderRow(
              icon: Icons.calendar_today,
              label: 'DATE',
              value: DateFormat('yyyy/MM/dd')
                  .format(order.createdAt ?? DateTime.now()),
            ),
            Row(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    getDisplayStatus(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.approvedOrRejected != null)
              _OrderRow(
                icon: Icons.check_circle_outline,
                label: 'APPROVED/REJECTED',
                value: order.approvedOrRejected!,
              ),
            _OrderRow(
              icon: Icons.update,
              label: 'LAST UPDATE',
              value: DateFormat('yyyy/MM/dd')
                  .format(order.updatedAt ?? DateTime.now()),
            ),
            _OrderRow(
              icon: Icons.attach_money,
              label: 'AMOUNT',
              value: 'Rs. ${order.price?.toStringAsFixed(0) ?? '0'}',
            ),
            _OrderRow(
              icon: Icons.scale,
              label: 'QUANTITY',
              value: '${order.quantity ?? 0} Kg',
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;

  const _OrderRow({
    this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
