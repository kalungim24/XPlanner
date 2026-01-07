import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/reflection.dart';
import '../providers/note_provider.dart';
import '../providers/reflection_provider.dart';
import '../services/local_storage_service.dart';

class SampleDataService {
  static Future<void> populateData(BuildContext context) async {
    final storageService = LocalStorageService();

    // Wait a bit for providers to load their data
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if sample data has already been populated
    final hasBeenPopulated = await storageService.hasSampleDataBeenPopulated();
    if (hasBeenPopulated) {
      return;
    }

    // Also check if there's any saved data (user might have deleted sample data)
    final hasSavedData = await storageService.hasAnySavedData();
    if (hasSavedData) {
      // Mark as populated so we don't add sample data again
      await storageService.markSampleDataAsPopulated();
      return;
    }

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final reflectionProvider =
        Provider.of<ReflectionProvider>(context, listen: false);

    final now = DateTime.now();

    // Notes
    await noteProvider.addNote(Note(
      title: 'Project Ideas',
      content:
          '- AI Task Planner\n- Fitness Tracker with Social Features\n- Budget App for Students',
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

    // Mark that sample data has been populated
    await storageService.markSampleDataAsPopulated();
  }
}
