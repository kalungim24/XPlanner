import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  final NotificationService _notificationService = NotificationService();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await _storageService.loadTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _storageService.saveTasks(_tasks);
    
    // Schedule notification if reminder is enabled and due date exists
    if (task.hasReminder && task.dueDate != null) {
      final notificationId = _notificationService.getNotificationId(task.id);
      await _notificationService.scheduleTaskReminder(
        id: notificationId,
        title: 'Task Reminder: ${task.title}',
        body: task.description.isNotEmpty 
            ? '${task.description}\n\nDue: ${_formatDateTime(task.dueDate!)}'
            : 'Your task "${task.title}" is due soon!\n\nDue: ${_formatDateTime(task.dueDate!)}',
        scheduledDate: task.dueDate!,
      );
    }
    
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final oldTask = _tasks[index];
      
      // Cancel old notification if it existed
      if (oldTask.hasReminder) {
        final oldNotificationId = _notificationService.getNotificationId(oldTask.id);
        await _notificationService.cancelReminder(oldNotificationId);
      }
      
      _tasks[index] = task;
      await _storageService.saveTasks(_tasks);
      
      // Schedule new notification if reminder is enabled
      if (task.hasReminder && task.dueDate != null) {
        final notificationId = _notificationService.getNotificationId(task.id);
        await _notificationService.scheduleTaskReminder(
          id: notificationId,
          title: 'Task Reminder: ${task.title}',
          body: task.description.isNotEmpty 
              ? '${task.description}\n\nDue: ${_formatDateTime(task.dueDate!)}'
              : 'Your task "${task.title}" is due soon!\n\nDue: ${_formatDateTime(task.dueDate!)}',
          scheduledDate: task.dueDate!,
        );
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    
    // Cancel notification if it exists
    if (task.hasReminder) {
      final notificationId = _notificationService.getNotificationId(id);
      await _notificationService.cancelReminder(notificationId);
    }
    
    _tasks.removeWhere((t) => t.id == id);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  List<Task> get upcomingDeadlines {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _tasks.where((t) => 
      t.dueDate != null && 
      t.dueDate!.isAfter(now) && 
      t.dueDate!.isBefore(nextWeek) &&
      !t.isCompleted
    ).toList();
  }

  List<Task> get topPriorities {
    // Simple logic: High priority, not completed, due soonest
    final activeTasks = _tasks.where((t) => !t.isCompleted).toList();
    activeTasks.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index); // High to Low
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });
    return activeTasks.take(3).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y - h:mm a').format(dateTime);
  }
}
