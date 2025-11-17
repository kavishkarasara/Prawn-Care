/// Represents a supply order placed by a supplier for specific items.
/// This model contains details about the order, including supplier, item, quantity, status, and optional reason.
class SupplyOrder {
  /// Unique identifier for the supply order.
  final String id;

  /// Identifier of the supplier placing the order.
  final String supplierId;

  /// Identifier of the item being ordered.
  final String itemId;

  /// Name of the item being ordered.
  final String itemName;

  /// Date when the order was placed.
  final String orderDate;

  /// Quantity of the item ordered.
  final int quantity;

  /// Current status of the order (e.g., new, approved, rejected).
  final String status;

  /// Optional reason for the order status or rejection.
  final String? reason;

  /// Constructor for SupplyOrder.
  SupplyOrder({
    required this.id,
    required this.supplierId,
    required this.itemId,
    required this.itemName,
    required this.orderDate,
    required this.quantity,
    required this.status,
    this.reason,
  });

  /// Factory constructor to create a SupplyOrder from a JSON map.
  /// Handles null values and type conversions safely.
  factory SupplyOrder.fromJson(Map<String, dynamic> json) {
    return SupplyOrder(
      id: json['supply_order_id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      orderDate: json['order_date']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      status: json['status']?.toString().toLowerCase() ?? 'new',
      reason: json['reason']?.toString(),
    );
  }

  /// Converts the SupplyOrder to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'item_id': itemId,
      'item_name': itemName,
      'order_date': orderDate,
      'quantity': quantity,
      'status': status,
      'reason': reason,
    };
  }
}
