import 'dart:math';

import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

class QuoteProvider extends ChangeNotifier {
  final List<Map<String, String>> _quotes = [
    {
      'text': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain'
    },
    {
      'text': 'Start where you are. Use what you have. Do what you can.',
      'author': 'Arthur Ashe'
    },
    {
      'text':
          'It does not matter how slowly you go as long as you do not stop.',
      'author': 'Confucius'
    },
    {
      'text':
          'Success is the sum of small efforts repeated day in and day out.',
      'author': 'Robert Collier'
    },
    {
      'text': 'You miss 100% of the shots you don’t take.',
      'author': 'Wayne Gretzky'
    },
    {
      'text':
          'The best time to plant a tree was 20 years ago. The second best time is now.',
      'author': 'Chinese Proverb'
    },
    {
      'text': 'Don’t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson'
    },
    {
      'text':
          'The only way to achieve the impossible is to believe it is possible.',
      'author': 'Charles Kingsleigh'
    },
  ];

  int _currentIndex = 0;
  final _storage = LocalStorageService();

  String get quoteText => _quotes[_currentIndex]['text']!;
  String get quoteAuthor => _quotes[_currentIndex]['author']!;

  Future<void> initQuote() async {
    final lastIndex = await _storage.loadQuoteIndex();
    final rand = Random();

    // Pick a new index; ensure it's different from lastIndex when possible
    int newIndex = rand.nextInt(_quotes.length);
    if (lastIndex != null && _quotes.length > 1) {
      // try again if equal
      int attempts = 0;
      while (newIndex == lastIndex && attempts < 5) {
        newIndex = rand.nextInt(_quotes.length);
        attempts++;
      }
    }

    _currentIndex = newIndex;
    await _storage.saveQuoteIndex(_currentIndex);
    notifyListeners();
  }
}
