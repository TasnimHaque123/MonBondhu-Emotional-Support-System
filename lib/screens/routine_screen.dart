import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../providers/auth_provider.dart';
import '../models/routine.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentUser;
      if (user != null) {
        Provider.of<RoutineProvider>(
          context,
          listen: false,
        ).initialize(user.id!);
      }
    });
  }

  void _addNewTask() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null || _taskController.text.trim().isEmpty) return;

    final newRoutine = Routine(
      userId: user.id!,
      title: _taskController.text.trim(),
      type: 'TASK',
    );

    Provider.of<RoutineProvider>(context, listen: false).addRoutine(newRoutine);
    _taskController.clear();
  }

  void _generateAiRoutine() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    final routineProvider = Provider.of<RoutineProvider>(
      context,
      listen: false,
    );

    await routineProvider.generateAiRoutine(user.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'AI has created a personalized daily routine for you! 💚',
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            tooltip: 'Ask AI for Suggestions',
            onPressed: routineProvider.isLoading ? null : _generateAiRoutine,
          ),
        ],
      ),
      body: Column(
        children: [
          if (routineProvider.isLoading) const LinearProgressIndicator(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task or habit...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _addNewTask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          Expanded(
            child: routineProvider.routines.isEmpty
                ? const Center(child: Text('No routines planned for today.'))
                : ListView.builder(
                    itemCount: routineProvider.routines.length,
                    itemBuilder: (context, index) {
                      final routine = routineProvider.routines[index];
                      return Dismissible(
                        key: Key(routine.id.toString()),
                        onDismissed: (_) {
                          routineProvider.deleteRoutine(
                            routine.id!,
                            routine.userId,
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: routine.isCompleted,
                            onChanged: (_) =>
                                routineProvider.toggleRoutine(routine),
                          ),
                          title: Text(
                            routine.title,
                            style: TextStyle(
                              decoration: routine.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: routine.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text(routine.type),
                          trailing: Icon(
                            routine.type == 'HABIT'
                                ? Icons.repeat
                                : Icons.task_alt,
                            size: 16,
                            color: Colors.teal[200],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Quick Habits Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Reminders',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHabitChip('💧 Water', Colors.blue),
                    _buildHabitChip('🧘 Break', Colors.orange),
                    _buildHabitChip('🏃 Exercise', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitChip(String label, Color color) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final user = Provider.of<AuthProvider>(
          context,
          listen: false,
        ).currentUser;
        if (user != null) {
          Provider.of<RoutineProvider>(
            context,
            listen: false,
          ).addRoutine(Routine(userId: user.id!, title: label, type: 'HABIT'));
        }
      },
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }
}
