/// Enumeration representing the possible statuses of an order.
/// This enum is used to track the progress of orders through different stages.
enum OrderStatus {
  /// The order is being packed for shipment.
  packing,

  /// The order is on its way to the delivery location.
  onTheWay,

  /// The order has been successfully delivered.
  delivered,
}
