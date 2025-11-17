import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding_schedule.dart';
import '../models/supply_order.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 10);

  Future<List<FeedingScheduleItem>> getFeedingSchedule() async {
    try {
      final uri = Uri.parse('$BACKEND_BASE_URL/api/mobile/worker/time-table');
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FeedingScheduleItem.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load feeding schedule. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while fetching feeding schedule');
    } on http.ClientException catch (e) {
      throw Exception(
          'Network error while fetching feeding schedule: ${e.message}');
    } on FormatException {
      throw Exception('Invalid JSON format for feeding schedule data');
    }
  }

  Future<List<SupplyOrder>> getSupplyOrders(String supplierId) async {
    try {
      final uri = Uri.parse(
          '$BACKEND_BASE_URL/api/mobile/supplier/supply-orders?supplier_id=$supplierId');
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SupplyOrder.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load supply orders. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while fetching supply orders');
    } on http.ClientException catch (e) {
      throw Exception(
          'Network error while fetching supply orders: ${e.message}');
    } on FormatException {
      throw Exception('Invalid JSON format for supply orders data');
    }
  }

  Future<void> updateSupplyOrderStatus(
      String supplierId, String orderId, String status) async {
    try {
      print('supplierId: $supplierId, orderId: $orderId');
      final supplierIdInt = int.tryParse(supplierId);
      final orderIdInt = int.tryParse(orderId);
      if (supplierIdInt == null || orderIdInt == null) {
        throw Exception(
            'Invalid supplierId or orderId: supplierId=$supplierId, orderId=$orderId');
      }
      final body = {
        'supplier_id': supplierIdInt,
        'order_id': orderIdInt,
        'status': status
      };
      print('Sending JSON: ${jsonEncode(body)}');
      final uri = Uri.parse(
          '$BACKEND_BASE_URL/api/mobile/supplier/update-order-status');
      final response = await http
          .patch(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(timeout);

      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update order status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while updating order status');
    } on http.ClientException catch (e) {
      throw Exception(
          'Network error while updating order status: ${e.message}');
    }
  }

  Future<List<String>> getAvailablePrawnTypes() async {
    try {
      final uri = Uri.parse(
          '$BACKEND_BASE_URL/api/mobile/customer/available-prawn-types');
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> prawnTypes = data['prawnTypes'];
        return prawnTypes.map((e) => e.toString()).toList();
      } else {
        throw Exception(
            'Failed to load prawn types. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while fetching prawn types');
    } on http.ClientException catch (e) {
      throw Exception('Network error while fetching prawn types: ${e.message}');
    } on FormatException {
      throw Exception('Invalid JSON format for prawn types data');
    }
  }

  Future<List<Order>> getCustomerOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri =
          Uri.parse('$BACKEND_BASE_URL/api/mobile/customer/Order-Status');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load customer orders. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while fetching customer orders');
    } on http.ClientException catch (e) {
      throw Exception(
          'Network error while fetching customer orders: ${e.message}');
    } on FormatException {
      throw Exception('Invalid JSON format for customer orders data');
    }
  }
}
