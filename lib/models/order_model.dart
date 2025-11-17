/// Represents an order item with customer and delivery details.
/// This model is used for displaying and managing order information in the UI.
class OrderItem {
  /// Unique identifier for the order.
  final String orderId;

  /// Name of the customer who placed the order.
  final String customerName;

  /// The product being ordered.
  final String product;

  /// Quantity of the product ordered.
  final String quantity;

  /// Scheduled delivery date for the order.
  final String deliveryDate;

  /// Current status of the order (e.g., pending, delivered).
  String status;

  /// Total amount for the order.
  final String totalAmount;

  /// Contact number of the customer.
  final String contactNumber;

  /// Delivery address for the order.
  final String address;

  /// Timestamp when the order was last updated.
  final DateTime? updatedAt;

  /// Constructor for OrderItem.
  OrderItem({
    required this.orderId,
    required this.customerName,
    required this.product,
    required this.quantity,
    required this.deliveryDate,
    required this.status,
    required this.totalAmount,
    required this.contactNumber,
    required this.address,
    this.updatedAt,
  });
}
