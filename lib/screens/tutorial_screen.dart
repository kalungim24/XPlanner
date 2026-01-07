import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_storage_service.dart';
import '../providers/task_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/habit_provider.dart';
import 'main_scaffold.dart';
import 'todo_list_screen.dart';
import 'schedule_screen.dart';
import 'habit_tracker_screen.dart';
import 'deadlines_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<String> _steps = [
    'Welcome',
    'Add Task',
    'Add Schedule',
    'Add Habit',
    'View Deadlines',
    'Finish'
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildStaticPage({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _finishTutorial() async {
    await LocalStorageService().markTutorialAsSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScaffold(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInteractiveStep(
      {required String title,
      required String body,
      required VoidCallback onOpen,
      required bool done}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open')),
          const SizedBox(height: 8),
          // No automatic 'Show menu' action; user can open the menu manually from the target screen.

          TextButton(
            onPressed: () => _skipCurrentStep(),
            child: const Text('Skip this step',
                style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Done?'),
              const SizedBox(width: 8),
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? Colors.green : Colors.grey),
            ],
          )
        ],
      ),
    );
  }

  bool _hasTask() {
    final prov = Provider.of<TaskProvider>(context, listen: false);
    return prov.tasks.isNotEmpty;
  }

  bool _hasSchedule() {
    final prov = Provider.of<ScheduleProvider>(context, listen: false);
    return prov.entries.isNotEmpty;
  }

  bool _hasHabit() {
    final prov = Provider.of<HabitProvider>(context, listen: false);
    return prov.habits.isNotEmpty;
  }

  bool _hasDeadline() {
    final prov = Provider.of<TaskProvider>(context, listen: false);
    return prov.tasks.any((t) => t.dueDate != null);
  }

  void _skipCurrentStep() {
    if (_page == _steps.length - 1) {
      _finishTutorial();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _openDeadlinesFromTutorial() async {
    final res = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DeadlinesScreen()));
    if (res == true) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    setState(() {});
  }

  void _openTasksFromTutorial() async {
    final res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const TodoListScreen(tutorialMode: true)));
    if (res == true) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    setState(() {});
  }

  void _openScheduleFromTutorial() async {
    final res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const ScheduleScreen(tutorialMode: true)));
    if (res == true) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    setState(() {});
  }

  void _openHabitsFromTutorial() async {
    final res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const HabitTrackerScreen(tutorialMode: true)));
    if (res == true) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          TextButton(
            onPressed: () {
              // Show confirmation dialog when skipping
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Skip Tutorial?'),
                  content: const Text(
                      'You can always access the tutorial from the menu later.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _finishTutorial();
                      },
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _steps.length,
              itemBuilder: (context, i) {
                final step = _steps[i];
                switch (step) {
                  case 'Welcome':
                    return _buildStaticPage(
                      title: 'Welcome to XPlanner',
                      body:
                          'XPlanner helps you organize tasks, track habits, and reflect daily.',
                    );
                  case 'Add Task':
                    return _buildInteractiveStep(
                      title: 'Add your first Task',
                      body:
                          'Tap the button below to open Tasks and add one task with a deadline. When you set a date, you can enable reminders to get notifications. You must add one task to continue. If you want to view the app menu, open the Tasks screen and tap the 3-bar (hamburger) icon in the top-left.',
                      onOpen: () => _openTasksFromTutorial(),
                      done: _hasTask(),
                    );
                  case 'Add Schedule':
                    return _buildInteractiveStep(
                      title: 'Add a Schedule Entry',
                      body:
                          'Open Schedule and add a class or event for today. You must add one to continue. To access the app menu, tap the 3-bar (hamburger) icon in the top-left of the Schedule screen.',
                      onOpen: () => _openScheduleFromTutorial(),
                      done: _hasSchedule(),
                    );
                  case 'Add Habit':
                    return _buildInteractiveStep(
                      title: 'Add a Habit',
                      body:
                          'Open Habits and create one habit (e.g. Read 30 mins). You must add one to continue. To view the app menu, open Habits and tap the 3-bar (hamburger) icon in the top-left.',
                      onOpen: () => _openHabitsFromTutorial(),
                      done: _hasHabit(),
                    );
                  case 'View Deadlines':
                    return _buildInteractiveStep(
                      title: 'View Deadlines',
                      body:
                          'Open Deadlines to see all your tasks with due dates in a calendar view. Make sure you have at least one task with a deadline.',
                      onOpen: _openDeadlinesFromTutorial,
                      done: _hasDeadline(),
                    );
                  case 'Finish':
                  default:
                    return _buildStaticPage(
                        title: 'All Set!',
                        body:
                            'You have completed the quick tutorial. Tap Get Started to go to the app.');
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                      _steps.length,
                      (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _page == i ? 16 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: _page == i
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(8)),
                          )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final step = _steps[_page];
                    if (step == 'Finish') {
                      _finishTutorial();
                      return;
                    }

                    // For interactive steps, only allow advancing if done
                    if (step == 'Add Task' && !_hasTask()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please add a task to continue')));
                      return;
                    }
                    if (step == 'Add Schedule' && !_hasSchedule()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Please add a schedule entry to continue')));
                      return;
                    }
                    if (step == 'Add Habit' && !_hasHabit()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please add a habit to continue')));
                      return;
                    }
                    if (step == 'View Deadlines' && !_hasDeadline()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Please add a task with a deadline to continue')));
                      return;
                    }

                    if (_page == _steps.length - 1) {
                      _finishTutorial();
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  },
                  child:
                      Text(_page == _steps.length - 1 ? 'Get Started' : 'Next'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
