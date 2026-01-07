import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_entry.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  final bool tutorialMode;
  const ScheduleScreen({super.key, this.tutorialMode = false});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.tutorialMode) {
        _showAddEntryDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final events =
        scheduleProvider.getEntriesForDay(_selectedDay ?? DateTime.now());

    return Scaffold(
      drawer: widget.tutorialMode
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary),
                    child: const Text('App Menu',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('Skip this tutorial step'),
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 150),
                          () => Navigator.pop(context, true));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('How to use the 3-bar menu'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                  title: const Text('Menu'),
                                  content: const Text(
                                      'The 3-bar hamburger opens this menu where you can access Tutorial and Settings.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'))
                                  ]));
                    },
                  ),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        title: const Text('Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEntryDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
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
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: event.color.withOpacity(0.2),
                  child: ListTile(
                    leading: Icon(Icons.class_, color: event.color),
                    title: Text(event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}\n${event.location}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        scheduleProvider.deleteEntry(event.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class/Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Title (e.g. Math 101)'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                    labelText: 'Location (e.g. Room 302)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (time != null) startTime = time;
                    },
                    child: const Text('Start Time'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (time != null) endTime = time;
                    },
                    child: const Text('End Time'),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final now = _selectedDay ?? DateTime.now();
                final start = DateTime(now.year, now.month, now.day,
                    startTime.hour, startTime.minute);
                final end = DateTime(
                    now.year, now.month, now.day, endTime.hour, endTime.minute);

                Provider.of<ScheduleProvider>(context, listen: false).addEntry(
                  ScheduleEntry(
                    title: titleController.text,
                    location: locationController.text,
                    startTime: start,
                    endTime: end,
                  ),
                );
                Navigator.pop(context);
                // If in tutorial mode, return to tutorial and indicate success
                if (widget.tutorialMode) {
                  Navigator.pop(context, true);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
