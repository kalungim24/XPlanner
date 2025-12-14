import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habitProvider.habits.length,
        itemBuilder: (context, index) {
          final habit = habitProvider.habits[index];
          return _buildHabitCard(context, habit, habitProvider);
        },
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, HabitProvider provider) {
    final today = DateTime.now();
    final isCompletedToday = habit.isCompletedOn(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(habit.title, style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange),
                    Text('${habit.currentStreak}'),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => provider.deleteHabit(habit.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mark for today:'),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: isCompletedToday,
                    onChanged: (val) {
                      provider.toggleHabitCompletion(habit.id, today);
                    },
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Last 7 Days:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final date = today.subtract(Duration(days: 6 - index));
                final isCompleted = habit.isCompletedOn(date);
                return Column(
                  children: [
                    Text(DateFormat('E').format(date)[0], style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted 
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Habit'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Habit Name (e.g. Read 30 mins)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Provider.of<HabitProvider>(context, listen: false).addHabit(
                  Habit(title: titleController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
