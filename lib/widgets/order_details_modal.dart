import 'package:flutter/material.dart';
import '../models/order_model.dart';

void showOrderDetails(BuildContext context, OrderItem order,
    Function(OrderItem, String) onStatusUpdate) {
  String? selectedStatus = null;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              _buildHandleBar(),
              _buildHeader(context, 'Order Details'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderInfo(order),
                      const SizedBox(height: 20),
                      _buildStatusDropdown(order.status, selectedStatus,
                          (newValue) {
                        setState(() => selectedStatus = newValue!);
                      }),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: selectedStatus != null
                              ? () {
                                  onStatusUpdate(order, selectedStatus!);
                                  Navigator.pop(context);
                                }
                              : null,
                          child: const Text('Submit Status'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void showCompletedOrderDetails(BuildContext context, OrderItem order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          _buildHandleBar(),
          _buildHeader(context, 'Completed Order Details'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildOrderInfo(order),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildHandleBar() {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    width: 50,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

Widget _buildHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}

Widget _buildOrderInfo(OrderItem order) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Order ID: ${order.orderId}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Customer: ${order.customerName}',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Product: ${order.product}',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Quantity: ${order.quantity}',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Delivery Date: ${order.deliveryDate}',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusBackgroundColor(order.status),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Status: ${order.status}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}

Widget _buildStatusDropdown(
    String currentStatus, String? selectedStatus, Function(String?) onChanged) {
  List<String> options;
  if (currentStatus == 'New') {
    options = ['Processing', 'Delivered', 'Complete order'];
  } else if (currentStatus == 'Processing') {
    options = ['Delivered', 'Complete order'];
  } else if (currentStatus == 'Delivered') {
    options = ['Complete order'];
  } else {
    options = [];
  }
  return DropdownButtonFormField<String>(
    value: selectedStatus,
    items: options
        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
        .toList(),
    onChanged: onChanged,
    decoration: const InputDecoration(labelText: 'Update Status'),
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'new':
      return Colors.orange;
    case 'Pending':
      return Colors.grey;
    case 'Processing':
      return Colors.blue;
    case 'Delivered':
      return Colors.purple;
    case 'Completed':
    case 'Complete order':
      return Colors.green;
    default:
      return Colors.black;
  }
}

Color _getStatusBackgroundColor(String status) {
  switch (status) {
    case 'new':
      return Colors.orange.shade100;
    case 'Pending':
      return Colors.grey.shade100;
    case 'Processing':
      return Colors.blue.shade100;
    case 'Delivered':
      return Colors.purple.shade100;
    case 'Completed':
    case 'Complete order':
      return Colors.green.shade100;
    default:
      return Colors.grey.shade100;
  }
}
