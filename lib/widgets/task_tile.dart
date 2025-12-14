import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool showDate;

  const TaskTile({super.key, required this.task, this.showDate = false});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (val) {
            taskProvider.toggleTaskCompletion(task.id);
          },
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: showDate && task.dueDate != null
            ? Text(
                'Due: ${DateFormat('MMM d, h:mm a').format(task.dueDate!)}',
                style: TextStyle(color: priorityColor),
              )
            : Text(task.category.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
