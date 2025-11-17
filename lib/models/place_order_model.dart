import 'package:file_picker/file_picker.dart';

/// Model representing the data required to place an order.
/// This includes location, prawn type, quantity, price, and optional payment receipt.
class PlaceOrderModel {
  /// The delivery location for the order.
  final String location;

  /// The type of prawn being ordered.
  final String prawnType;

  /// The quantity of prawns ordered.
  final double quantity;

  /// The price per unit for the prawns.
  final double price;

  /// Optional payment receipt file attached to the order.
  final PlatformFile? paymentReceipt;

  /// Constructor for PlaceOrderModel.
  PlaceOrderModel({
    required this.location,
    required this.prawnType,
    required this.quantity,
    required this.price,
    this.paymentReceipt,
  });
}
