import 'package:prawn__farm/models/place_order_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';

class PlaceOrderService {
  Future<void> submitOrder(PlaceOrderModel order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw 'User not authenticated.';
      }

      final uri =
          Uri.parse('$BACKEND_BASE_URL/api/mobile/customer/place-order');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['prawn_type'] = order.prawnType
        ..fields['quantity'] = order.quantity.toString()
        ..fields['price'] = order.price.toString()
        ..fields['location'] = order.location;

      if (order.paymentReceipt != null) {
        if (order.paymentReceipt!.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'payment_receipt',
            order.paymentReceipt!.bytes!,
            filename: order.paymentReceipt!.name,
            contentType: MediaType('application', 'octet-stream'),
          ));
        } else if (order.paymentReceipt!.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'payment_receipt',
            order.paymentReceipt!.path!,
            filename: order.paymentReceipt!.name,
            contentType: MediaType('application', 'octet-stream'),
          ));
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        try {
          // ignore: unused_local_variable
          final data = jsonDecode(responseBody);
          // Success
        } catch (e) {
          throw 'Unexpected response format';
        }
      } else {
        try {
          final error = jsonDecode(responseBody);
          throw error['error'] ?? 'Failed to place order';
        } catch (e) {
          throw responseBody; // If not JSON, throw the raw response
        }
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}
