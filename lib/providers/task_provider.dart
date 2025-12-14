import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/local_storage_service.dart';

class TaskProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
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
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
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
}
