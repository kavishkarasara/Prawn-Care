import 'package:flutter/material.dart';
import '../models/supply_order.dart';
import '../services/api_service.dart';

class SupplyOrderListItem extends StatefulWidget {
  final SupplyOrder order;
  final ApiService apiService;
  final VoidCallback onUpdate;
  final String supplierId;

  const SupplyOrderListItem({
    super.key,
    required this.order,
    required this.apiService,
    required this.onUpdate,
    required this.supplierId,
  });

  @override
  State<SupplyOrderListItem> createState() => _SupplyOrderListItemState();
}

class _SupplyOrderListItemState extends State<SupplyOrderListItem> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final color = _getBackgroundColor();
    final borderColor = _getBorderColor(color);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: ${widget.order.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Item: ${widget.order.itemName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quantity: ${widget.order.quantity}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order Date: ${_formatOrderDate(widget.order.orderDate)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${widget.order.status}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (widget.order.status == 'rejected' &&
              widget.order.reason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: ${widget.order.reason}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 10),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.order.status) {
      case 'new':
      case 'pending':
        return Colors.amber.shade50;
      case 'processing':
        return Colors.cyan.shade50;
      case 'finished':
        return Colors.green.shade50;
      case 'delivered':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor(Color bgColor) {
    if (bgColor == Colors.amber.shade50) return Colors.amber.shade100;
    if (bgColor == Colors.cyan.shade50) return Colors.cyan.shade100;
    if (bgColor == Colors.green.shade50) return Colors.green.shade100;
    if (bgColor == Colors.blue.shade50) return Colors.blue.shade100;
    return Colors.grey.shade100;
  }

  Widget _buildActionButtons(BuildContext context) {
    if (widget.order.status == 'rejected' ||
        widget.order.status == 'delivered') {
      return const SizedBox.shrink();
    }

    List<String> options = [];
    bool isNew =
        widget.order.status == 'new' || widget.order.status == 'pending';

    if (isNew) {
      options = ['processing', 'finished', 'delivered'];
    } else if (widget.order.status == 'processing') {
      options = ['finished', 'delivered'];
    } else if (widget.order.status == 'finished') {
      options = ['delivered'];
    }

    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Update Status',
                ),
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'delivered'
                        ? 'HAND OVER TO DELIVERY'
                        : value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed:
                  _selectedStatus != null ? () => _submitStatusChange() : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  void _submitStatusChange() async {
    if (_selectedStatus == null) return;

    try {
      await widget.apiService.updateSupplyOrderStatus(
          widget.supplierId, widget.order.id, _selectedStatus!);
      setState(() {
        _selectedStatus = null;
      });
      widget.onUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  String _formatOrderDate(String dateString) {
    try {
      // Remove time part if present (e.g., "2023-10-15T10:30:00" -> "2023-10-15")
      final datePart = dateString.split('T').first;
      final parts = datePart.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2];
        return '$year - $month - $day';
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
}
