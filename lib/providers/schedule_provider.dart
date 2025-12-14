import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';
import '../services/local_storage_service.dart';

class ScheduleProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  List<ScheduleEntry> _entries = [];

  List<ScheduleEntry> get entries => _entries;

  ScheduleProvider() {
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    _entries = await _storageService.loadSchedule();
    notifyListeners();
  }

  Future<void> addEntry(ScheduleEntry entry) async {
    _entries.add(entry);
    await _storageService.saveSchedule(_entries);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _storageService.saveSchedule(_entries);
    notifyListeners();
  }

  List<ScheduleEntry> getEntriesForDay(DateTime date) {
    return _entries.where((e) => 
      e.startTime.year == date.year && 
      e.startTime.month == date.month && 
      e.startTime.day == date.day
    ).toList();
  }
}
