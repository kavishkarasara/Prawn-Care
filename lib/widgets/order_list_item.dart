import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'order_details_modal.dart';

class OrderListItem extends StatelessWidget {
  final OrderItem order;
  final Function(OrderItem, String) onStatusUpdate;

  const OrderListItem(
      {super.key, required this.order, required this.onStatusUpdate});

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateString; // Fallback to original string if parsing fails
    }
  }

  Color _getBackgroundColor(String status) {
    switch (status) {
      case 'new':
      case 'New':
        return Colors.yellow.shade50;
      case 'processing':
      case 'Processing':
        return Colors.blue.shade50;
      case 'Complete order':
      case 'Completed':
        return Colors.green.shade50;
      case 'Delivered':
        return Colors.purple.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'new':
      case 'New':
        return Colors.yellow.shade100;
      case 'processing':
      case 'Processing':
        return Colors.blue.shade100;
      case 'Complete order':
      case 'Completed':
        return Colors.green.shade100;
      case 'Delivered':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
      case 'New':
        return Colors.orange;
      case 'Pending':
        return Colors.grey;
      case 'processing':
      case 'Processing':
        return Colors.blue;
      case 'Delivered':
        return Colors.purple;
      case 'Complete order':
      case 'Completed':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOrderDetails(context, order, onStatusUpdate),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getBackgroundColor(order.status),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _getBorderColor(order.status),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Order ID: ',
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                          letterSpacing: 0.5,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                      height: 1.3,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              TextSpan(
                                text: order.orderId,
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          height: 1.3,
                                          letterSpacing: 0.5,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      height: 1.3,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Product: ',
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                          letterSpacing: 0.5,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                      height: 1.3,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              TextSpan(
                                text: order.product,
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          height: 1.3,
                                          letterSpacing: 0.5,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      height: 1.3,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Quantity: ',
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                          letterSpacing: 0.5,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                      height: 1.3,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              TextSpan(
                                text: order.quantity,
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          height: 1.3,
                                          letterSpacing: 0.5,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      height: 1.3,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Created Date: ',
                                      style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade700,
                                                height: 1.3,
                                                letterSpacing: 0.5,
                                              ) ??
                                          const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                            height: 1.3,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                    TextSpan(
                                      text: _formatDate(order.deliveryDate),
                                      style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                height: 1.3,
                                                letterSpacing: 0.5,
                                              ) ??
                                          const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            height: 1.3,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Chip(
                  label: Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(order.status),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
