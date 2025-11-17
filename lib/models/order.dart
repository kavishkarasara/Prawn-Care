/// Represents an order in the prawn farm system.
/// This model contains details about the order such as ID, product, quantity, price, status, and timestamps.
class Order {
  /// Unique identifier for the order.
  final int? orderId;

  /// The type of product (e.g., prawn type) being ordered.
  final String? product;

  /// The quantity of the product ordered.
  final int? quantity;

  /// The price per unit of the product.
  final double? price;

  /// The current status of the order (e.g., pending, approved, rejected).
  final String? status;

  /// Additional information about approval or rejection.
  final String? approvedOrRejected;

  /// The date and time when the order was created.
  final DateTime? createdAt;

  /// The date and time when the order was last updated.
  final DateTime? updatedAt;

  /// Constructor for Order.
  Order({
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.status,
    this.approvedOrRejected,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create an Order from a JSON map.
  /// Handles type conversions for orderId, quantity, and price to ensure compatibility with different data sources.
  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle orderId: could be int or String
    int orderId = 0;
    if (json['order_id'] is int) {
      orderId = json['order_id'];
    } else if (json['order_id'] is String) {
      orderId = int.tryParse(json['order_id']) ?? 0;
    }

    // Handle quantity: could be int or String
    int quantity = 0;
    if (json['quantity'] is int) {
      quantity = json['quantity'];
    } else if (json['quantity'] is String) {
      quantity = int.tryParse(json['quantity']) ?? 0;
    }

    // Handle price: could be num or String
    double price = 0.0;
    if (json['price'] is num) {
      price = json['price'].toDouble();
    } else if (json['price'] is String) {
      price = double.tryParse(json['price']) ?? 0.0;
    }

    return Order(
      orderId: orderId,
      product: json['prawn_type'] as String?,
      quantity: quantity,
      price: price,
      status: json['status'] as String?,
      approvedOrRejected: json['approved_or_rejected'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
