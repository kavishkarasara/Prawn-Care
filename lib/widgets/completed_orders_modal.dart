import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'completed_order_list_item.dart';

void showCompletedOrdersModal(
    BuildContext context, List<OrderItem> completedOrders) {
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
          _buildHeader(context, 'Completed Orders'),
          Expanded(
            child: completedOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: completedOrders.length,
                    itemBuilder: (context, index) {
                      final order = completedOrders[index];
                      return CompletedOrderListItem(order: order);
                    },
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

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.history,
          size: 80,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 20),
        Text(
          'No completed orders yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}
