import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reflection_provider.dart';
import '../models/reflection.dart';

class DailyReflectionScreen extends StatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final _accomplishmentsController = TextEditingController();
  final _improvementsController = TextEditingController();
  final _prioritiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reflection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildSection('What did I accomplish today?', _accomplishmentsController),
            const SizedBox(height: 16),
            _buildSection('What could be improved?', _improvementsController),
            const SizedBox(height: 16),
            _buildSection('What will I prioritize tomorrow?', _prioritiesController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveReflection,
                icon: const Icon(Icons.save),
                label: const Text('Save Reflection'),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const Center(child: Text('Past Reflections', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            _buildPastReflectionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildPastReflectionsList() {
    final reflections = Provider.of<ReflectionProvider>(context).reflections;
    if (reflections.isEmpty) return const Center(child: Text('No reflections yet.'));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reflections.length,
      itemBuilder: (context, index) {
        final reflection = reflections[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(DateFormat('MMM d, y').format(reflection.date)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Accomplishments:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(reflection.accomplishments),
                    const SizedBox(height: 8),
                    const Text('Improvements:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(reflection.improvements),
                    const SizedBox(height: 8),
                    const Text('Priorities:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(reflection.prioritiesForTomorrow),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveReflection() {
    if (_accomplishmentsController.text.isNotEmpty) {
      Provider.of<ReflectionProvider>(context, listen: false).addReflection(
        Reflection(
          date: DateTime.now(),
          accomplishments: _accomplishmentsController.text,
          improvements: _improvementsController.text,
          prioritiesForTomorrow: _prioritiesController.text,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reflection Saved!')));
      _accomplishmentsController.clear();
      _improvementsController.clear();
      _prioritiesController.clear();
    }
  }
}
