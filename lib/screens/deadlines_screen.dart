import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasksWithDeadlines = taskProvider.tasks.where((t) => t.dueDate != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadlines'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              return tasksWithDeadlines.where((t) => isSameDay(t.dueDate, day)).toList();
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildDeadlineList(tasksWithDeadlines),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineList(List<Task> tasks) {
    // Filter for selected day if any, else show all upcoming
    List<Task> displayTasks = tasks;
    if (_selectedDay != null) {
      displayTasks = tasks.where((t) => isSameDay(t.dueDate, _selectedDay)).toList();
    } else {
      displayTasks = tasks.where((t) => t.dueDate!.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
      displayTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    }

    if (displayTasks.isEmpty) {
      return const Center(child: Text('No deadlines found.'));
    }

    return ListView.builder(
      itemCount: displayTasks.length,
      itemBuilder: (context, index) {
        final task = displayTasks[index];
        final now = DateTime.now();
        final difference = task.dueDate!.difference(now);
        
        Color statusColor = Colors.green;
        String statusText = 'Upcoming';

        if (difference.inHours < 24 && difference.inHours > 0) {
          statusColor = Colors.red;
          statusText = 'Due in ${difference.inHours}h';
        } else if (difference.inDays < 7 && difference.inDays >= 0) {
          statusColor = Colors.orange;
          statusText = 'Due in ${difference.inDays}d';
        } else if (difference.isNegative) {
          statusColor = Colors.grey;
          statusText = 'Overdue';
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(Icons.timer, color: statusColor),
            ),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('MMM d, y - h:mm a').format(task.dueDate!)),
            trailing: Chip(
              label: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 10)),
              backgroundColor: statusColor,
            ),
          ),
        );
      },
    );
  }
}
