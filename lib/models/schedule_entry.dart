import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ScheduleEntry {
  final String id;
  String title;
  String location;
  DateTime startTime;
  DateTime endTime;
  Color color;

  ScheduleEntry({
    String? id,
    required this.title,
    this.location = '',
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.value,
    };
  }

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      color: Color(json['color']),
    );
  }
}
