import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/local_storage_service.dart';

class HabitProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    _habits = await _storageService.loadHabits();
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].toggleCompletion(date);
      await _storageService.saveHabits(_habits);
      notifyListeners();
    }
  }
}
