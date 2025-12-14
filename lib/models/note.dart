import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  String category;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.category = 'General',
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
    );
  }
}
