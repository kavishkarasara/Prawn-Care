/// Represents a message sent by a supplier.
/// This model contains the message ID, supplier ID, text content, and creation timestamp.
class Message {
  /// Unique identifier for the message.
  final String id;

  /// Identifier of the supplier who sent the message.
  final String supplierId;

  /// The text content of the message.
  final String text;

  /// The date and time when the message was created.
  final DateTime createdAt;

  /// Constructor for Message.
  Message({
    required this.id,
    required this.supplierId,
    required this.text,
    required this.createdAt,
  });

  /// Factory constructor to create a Message from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      supplierId: json['supplier_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
