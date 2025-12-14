import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/schedule_entry.dart';
import '../models/note.dart';
import '../models/habit.dart';
import '../models/reflection.dart';
import '../providers/task_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/note_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/reflection_provider.dart';

class SampleDataService {
  static Future<void> populateData(BuildContext context) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final reflectionProvider = Provider.of<ReflectionProvider>(context, listen: false);

    // Check if data already exists to avoid duplicates
    if (taskProvider.tasks.isNotEmpty || 
        scheduleProvider.entries.isNotEmpty || 
        noteProvider.notes.isNotEmpty) {
      return;
    }

    // Tasks
    final now = DateTime.now();
    await taskProvider.addTask(Task(
      title: 'Complete Math Assignment',
      description: 'Chapter 5 exercises 1-10',
      category: TaskCategory.school,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 1, hours: 5)),
    ));
    await taskProvider.addTask(Task(
      title: 'Buy Groceries',
      category: TaskCategory.personal,
      priority: TaskPriority.medium,
      dueDate: now.add(const Duration(days: 2)),
    ));
    await taskProvider.addTask(Task(
      title: 'Flutter App Project',
      description: 'Implement UI for the new feature',
      category: TaskCategory.project,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 5)),
    ));
    await taskProvider.addTask(Task(
      title: 'Read History Chapter',
      category: TaskCategory.school,
      priority: TaskPriority.low,
      dueDate: now.add(const Duration(days: 3)),
    ));

    // Schedule
    await scheduleProvider.addEntry(ScheduleEntry(
      title: 'Calculus II',
      location: 'Room 304',
      startTime: DateTime(now.year, now.month, now.day, 9, 0),
      endTime: DateTime(now.year, now.month, now.day, 10, 30),
      color: Colors.blue,
    ));
    await scheduleProvider.addEntry(ScheduleEntry(
      title: 'Physics Lab',
      location: 'Lab B',
      startTime: DateTime(now.year, now.month, now.day, 13, 0),
      endTime: DateTime(now.year, now.month, now.day, 15, 0),
      color: Colors.purple,
    ));

    // Habits
    await habitProvider.addHabit(Habit(title: 'Read 30 mins'));
    await habitProvider.addHabit(Habit(title: 'Drink 2L Water'));
    await habitProvider.addHabit(Habit(title: 'Code for 1 hour'));

    // Notes
    await noteProvider.addNote(Note(
      title: 'Project Ideas',
      content: '- AI Task Planner\n- Fitness Tracker with Social Features\n- Budget App for Students',
      category: 'Ideas',
    ));
    await noteProvider.addNote(Note(
      title: 'Shopping List',
      content: 'Milk, Eggs, Bread, Coffee',
      category: 'Personal',
    ));

    // Reflection (Yesterday)
    await reflectionProvider.addReflection(Reflection(
      date: now.subtract(const Duration(days: 1)),
      accomplishments: 'Finished the history essay and went to the gym.',
      improvements: 'Spent too much time on social media.',
      prioritiesForTomorrow: 'Focus on Math assignment.',
    ));
  }
}
