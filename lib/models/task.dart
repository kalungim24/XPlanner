import 'package:uuid/uuid.dart';

enum TaskCategory { school, personal, project }
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  TaskCategory category;
  TaskPriority priority;
  bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.category = TaskCategory.school,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'category': category.index,
      'priority': priority.index,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      category: TaskCategory.values[json['category']],
      priority: TaskPriority.values[json['priority']],
      isCompleted: json['isCompleted'],
    );
  }
}
