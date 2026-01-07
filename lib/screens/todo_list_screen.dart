import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class TodoListScreen extends StatefulWidget {
  final bool tutorialMode;
  const TodoListScreen({super.key, this.tutorialMode = false});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // If launched from tutorial, either open add dialog or show drawer based on flag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.tutorialMode) {
        _showAddTaskDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

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
                      Navigator.pop(context); // close drawer
                      // return to tutorial marking step as skipped
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
        title: const Text('Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'School'),
            Tab(text: 'Personal'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(taskProvider, TaskCategory.school),
          _buildTaskList(taskProvider, TaskCategory.personal),
          _buildTaskList(taskProvider, TaskCategory.project),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider, TaskCategory category) {
    final tasks = provider.tasks.where((t) => t.category == category).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No tasks in ${category.name}!',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Slidable(
          key: Key(task.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  provider.deleteTask(task.id);
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: TaskTile(task: task, showDate: true),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.school;
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDate;
    bool hasReminder = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: TaskCategory.values.map((c) {
                    return DropdownMenuItem(
                        value: c, child: Text(c.name.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(
                        value: p, child: Text(p.name.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedPriority = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(selectedDate == null
                        ? 'No Date Selected'
                        : selectedDate.toString().split(' ')[0]),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                          // Ask about reminder when date is selected
                          if (!hasReminder) {
                            final reminderResult = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Set Reminder?'),
                                content: const Text(
                                    'Would you like to receive a notification when this task is due?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('No Thanks'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Yes, Remind Me'),
                                  ),
                                ],
                              ),
                            );
                            if (reminderResult == true) {
                              setState(() => hasReminder = true);
                            }
                          }
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                if (selectedDate != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: hasReminder
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.grey[100],
                    child: CheckboxListTile(
                      title: const Text('Set Reminder',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          const Text('Get notified when the deadline arrives'),
                      value: hasReminder,
                      onChanged: (value) {
                        setState(() => hasReminder = value ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: Icon(
                        hasReminder
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: hasReminder
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
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
                  Provider.of<TaskProvider>(context, listen: false).addTask(
                    Task(
                      title: titleController.text,
                      category: selectedCategory,
                      priority: selectedPriority,
                      dueDate: selectedDate,
                      hasReminder: hasReminder && selectedDate != null,
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
      ),
    );
  }
}
