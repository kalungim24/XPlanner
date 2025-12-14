import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';

class NoteProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NoteProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _notes = await _storageService.loadNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _storageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _storageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _storageService.saveNotes(_notes);
      notifyListeners();
    }
  }
}
