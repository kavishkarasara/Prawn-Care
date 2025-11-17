import 'package:prawn__farm/models/order.dart';
import 'package:prawn__farm/models/order_status.dart';
import 'package:prawn__farm/models/tracking_data.dart';
import 'package:prawn__farm/services/api_service.dart';

class OrderService {
  // Method to fetch orders
  Future<List<Order>> fetchOrders() async {
    final apiService = ApiService();
    return await apiService.getCustomerOrders();
  }

  // Method to get tracking data
  Future<List<TrackingData>> getTrackingData() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    return [
      TrackingData(
        title: 'Order Packing',
        date: '2025/04/01',
        status: OrderStatus.packing,
      ),
      TrackingData(
        title: 'On The Way',
        date: 'In Progress',
        status: OrderStatus.onTheWay,
      ),
      TrackingData(
        title: 'Delivered',
        date: 'Pending',
        status: OrderStatus.delivered,
      ),
    ];
  }
}
