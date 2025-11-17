import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import 'order_details_modal.dart';

class CompletedOrderListItem extends StatelessWidget {
  final OrderItem order;

  const CompletedOrderListItem({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Completed':
      case 'Complete order':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'New';
      case 'Processing':
        return 'Processing';
      case 'Completed':
      case 'Complete order':
        return 'Completed';
      default:
        return status;
    }
  }

  Color _getBackgroundColor(String status) {
    switch (status) {
      case 'new':
        return Colors.yellow.shade50;
      case 'Processing':
        return Colors.blue.shade50;
      case 'Completed':
      case 'Complete order':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'new':
        return Colors.yellow.shade100;
      case 'Processing':
        return Colors.blue.shade100;
      case 'Completed':
      case 'Complete order':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showCompletedOrderDetails(context, order),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.orderId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Product: ${order.product}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              'Quantity: ${order.quantity}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Date: ${order.updatedAt != null ? DateFormat('yyyy-MM-dd').format(order.updatedAt!) : 'N/A'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Icon(
                  Icons.visibility,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
