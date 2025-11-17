/// Represents a special note created by a user, typically for workers to document important observations or tasks.
/// This model contains the note's details, including title, content, timestamps, and status.
class SpecialNote {
  /// Unique identifier for the special note.
  final String id;

  /// Identifier of the user who created the note.
  final String userId;

  /// Title of the special note.
  final String title;

  /// Content or description of the special note.
  final String content;

  /// Date and time when the note was created.
  final DateTime createdAt;

  /// Date and time when the note was last updated.
  final DateTime updatedAt;

  /// Current status of the note (e.g., Pending, Completed).
  final String status;

  /// Constructor for SpecialNote.
  SpecialNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  /// Factory constructor to create a SpecialNote from a JSON map.
  factory SpecialNote.fromJson(Map<String, dynamic> json) {
    return SpecialNote(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String? ?? 'Pending',
    );
  }

  /// Converts the SpecialNote to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
