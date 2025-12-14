import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  String title;
  List<DateTime> completedDates;
  int targetDaysPerWeek;

  Habit({
    String? id,
    required this.title,
    List<DateTime>? completedDates,
    this.targetDaysPerWeek = 7,
  }) : id = id ?? const Uuid().v4(),
       completedDates = completedDates ?? [];

  bool isCompletedOn(DateTime date) {
    return completedDates.any((d) => 
      d.year == date.year && d.month == date.month && d.day == date.day);
  }

  void toggleCompletion(DateTime date) {
    if (isCompletedOn(date)) {
      completedDates.removeWhere((d) => 
        d.year == date.year && d.month == date.month && d.day == date.day);
    } else {
      completedDates.add(date);
    }
  }

  int get currentStreak {
    // Simplified streak calculation
    int streak = 0;
    DateTime checkDate = DateTime.now();
    // Check today or yesterday to start
    if (!isCompletedOn(checkDate)) {
       checkDate = checkDate.subtract(const Duration(days: 1));
       if (!isCompletedOn(checkDate)) return 0;
    }
    
    while (isCompletedOn(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'targetDaysPerWeek': targetDaysPerWeek,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      completedDates: (json['completedDates'] as List).map((d) => DateTime.parse(d)).toList(),
      targetDaysPerWeek: json['targetDaysPerWeek'],
    );
  }
}
