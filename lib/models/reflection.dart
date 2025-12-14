import 'package:uuid/uuid.dart';

class Reflection {
  final String id;
  DateTime date;
  String accomplishments;
  String improvements;
  String prioritiesForTomorrow;

  Reflection({
    String? id,
    required this.date,
    required this.accomplishments,
    required this.improvements,
    required this.prioritiesForTomorrow,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'accomplishments': accomplishments,
      'improvements': improvements,
      'prioritiesForTomorrow': prioritiesForTomorrow,
    };
  }

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'],
      date: DateTime.parse(json['date']),
      accomplishments: json['accomplishments'],
      improvements: json['improvements'],
      prioritiesForTomorrow: json['prioritiesForTomorrow'],
    );
  }
}
