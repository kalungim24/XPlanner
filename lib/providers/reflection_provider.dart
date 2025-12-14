import 'package:flutter/material.dart';
import '../models/reflection.dart';
import '../services/local_storage_service.dart';

class ReflectionProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  List<Reflection> _reflections = [];

  List<Reflection> get reflections => _reflections;

  ReflectionProvider() {
    loadReflections();
  }

  Future<void> loadReflections() async {
    _reflections = await _storageService.loadReflections();
    notifyListeners();
  }

  Future<void> addReflection(Reflection reflection) async {
    _reflections.add(reflection);
    await _storageService.saveReflections(_reflections);
    notifyListeners();
  }
}
