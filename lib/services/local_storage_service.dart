import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/schedule_entry.dart';
import '../models/note.dart';
import '../models/habit.dart';
import '../models/reflection.dart';

class LocalStorageService {
  static const String _tasksKey = 'tasks';
  static const String _scheduleKey = 'schedule';
  static const String _notesKey = 'notes';
  static const String _habitsKey = 'habits';
  static const String _reflectionsKey = 'reflections';
  static const String _sampleDataPopulatedKey = 'sample_data_populated';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_tasksKey, encodedData);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_tasksKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveSchedule(List<ScheduleEntry> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(schedule.map((e) => e.toJson()).toList());
    await prefs.setString(_scheduleKey, encodedData);
  }

  Future<List<ScheduleEntry>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_scheduleKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((e) => ScheduleEntry.fromJson(e)).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(notes.map((e) => e.toJson()).toList());
    await prefs.setString(_notesKey, encodedData);
  }

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_notesKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((e) => Note.fromJson(e)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(habits.map((e) => e.toJson()).toList());
    await prefs.setString(_habitsKey, encodedData);
  }

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_habitsKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((e) => Habit.fromJson(e)).toList();
  }

  Future<void> saveReflections(List<Reflection> reflections) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(reflections.map((e) => e.toJson()).toList());
    await prefs.setString(_reflectionsKey, encodedData);
  }

  Future<List<Reflection>> loadReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_reflectionsKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((e) => Reflection.fromJson(e)).toList();
  }

  Future<bool> hasSampleDataBeenPopulated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sampleDataPopulatedKey) ?? false;
  }

  Future<void> markSampleDataAsPopulated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sampleDataPopulatedKey, true);
  }

  // Tutorial flag
  static const String _tutorialSeenKey = 'tutorial_seen';

  Future<void> markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialSeenKey, true);
  }

  Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialSeenKey) ?? false;
  }

  Future<bool> hasAnySavedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tasksKey) != null ||
        prefs.getString(_scheduleKey) != null ||
        prefs.getString(_notesKey) != null ||
        prefs.getString(_habitsKey) != null ||
        prefs.getString(_reflectionsKey) != null;
  }

  // Quote persistence
  static const String _quoteIndexKey = 'quote_index';

  Future<void> saveQuoteIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quoteIndexKey, index);
  }

  Future<int?> loadQuoteIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quoteIndexKey);
  }
}
