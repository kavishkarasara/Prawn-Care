import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

class WOrderService {
  Future<List<OrderItem>> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$BACKEND_BASE_URL/api/mobile/worker/New-Orders');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => OrderItem(
                orderId: item['order_id']?.toString() ?? '',
                customerName: '',
                product: item['prawn_type'] ?? '',
                quantity: item['quantity']?.toString() ?? '',
                deliveryDate: item['created_at'] ?? '',
                status: item['status'] ?? 'Pending',
                totalAmount: '',
                contactNumber: '',
                address: '',
                updatedAt: DateTime.tryParse(item['updated_at'] ?? ''),
              ))
          .toList();
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['message'] ?? errorBody['error'] ?? 'Unknown error';
      throw Exception(
          'Failed to load orders: $errorMessage (Status: ${response.statusCode})');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url =
        Uri.parse('$BACKEND_BASE_URL/api/mobile/worker/update-order-status');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'order_id': orderId.replaceFirst('#', ''),
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ??
            errorBody['error'] ??
            'Failed to update status';
        throw Exception(
            'Failed to update order status: $errorMessage (Status: ${response.statusCode})');
      } catch (e) {
        if (e is FormatException) {
          throw Exception(
              'Failed to update order status: Server error (Status: ${response.statusCode})');
        } else {
          rethrow;
        }
      }
    }
  }

  List<OrderItem> getInitialOrders() {
    return [
      OrderItem(
        orderId: "#12345",
        customerName: "Rahul Sharma",
        product: "Freshwater Prawns",
        quantity: "750 kg",
        deliveryDate: "18-Apr-2025",
        status: "Pending",
        totalAmount: "₹75,000",
        contactNumber: "+91 9876543210",
        address: "123 Farm Road, Kalutara, Western Province",
        updatedAt: DateTime.now(),
      ),
      OrderItem(
        orderId: "#12346",
        customerName: "Rahul Sharma",
        product: "Freshwater Prawns",
        quantity: "1000 kg",
        deliveryDate: "25-Apr-2025",
        status: "Confirmed",
        totalAmount: "₹1,00,000",
        contactNumber: "+91 9876543210",
        address: "456 Market Street, Colombo, Western Province",
        updatedAt: DateTime.now(),
      ),
      OrderItem(
        orderId: "#12347",
        customerName: "Rahul Sharma",
        product: "Freshwater Prawns",
        quantity: "1500 kg",
        deliveryDate: "30-Apr-2025",
        status: "Processing",
        totalAmount: "₹1,50,000",
        contactNumber: "+91 9876543210",
        address: "789 Business Center, Gampaha, Western Province",
        updatedAt: DateTime.now(),
      ),
      OrderItem(
        orderId: "#12348",
        customerName: "Priya Patel",
        product: "Tiger Prawns",
        quantity: "500 kg",
        deliveryDate: "02-May-2025",
        status: "Delivered",
        totalAmount: "₹60,000",
        contactNumber: "+91 9123456789",
        address: "321 Harbor View, Negombo, Western Province",
        updatedAt: DateTime.now(),
      ),
      OrderItem(
        orderId: "#12349",
        customerName: "Amit Kumar",
        product: "Jumbo Prawns",
        quantity: "800 kg",
        deliveryDate: "05-May-2025",
        status: "Pending",
        totalAmount: "₹1,20,000",
        contactNumber: "+91 8765432109",
        address: "654 Coastal Road, Panadura, Western Province",
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
