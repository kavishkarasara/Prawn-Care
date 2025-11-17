import 'package:flutter/material.dart';
import 'package:prawn__farm/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          OrderRow(label: 'ORDER ID', value: order.orderId?.toString() ?? '0'),
          OrderRow(label: 'PRODUCT', value: order.product ?? 'N/A'),
          OrderRow(
              label: 'DATE',
              value: order.createdAt?.toString().split(' ')[0] ?? 'N/A'),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (order.status == 'approved')
                      ? Colors.green
                      : const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (order.status == 'approved') ? 'Complete' : 'Processing',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.approvedOrRejected != null)
            OrderRow(
              label: 'APPROVED/REJECTED',
              value: order.approvedOrRejected!,
            ),
          OrderRow(
              label: 'AMOUNT',
              value: 'Rs. ${order.price?.toStringAsFixed(0) ?? '0'}'),
          OrderRow(label: 'QUANTITY', value: '${order.quantity ?? 0} Kg'),
        ],
      ),
    );
  }
}

class OrderRow extends StatelessWidget {
  final String label;
  final String value;

  const OrderRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
