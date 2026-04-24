import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/todo_item_model.dart';
import '../../services/notification_service.dart';
import '../../services/todo_service.dart';
import '../../theme/app_colors.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TodoService _todoService = TodoService();
  DateTime _selectedDate = DateTime.now();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  String? get _farmId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Daily Todo List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _userId == null || _farmId == null
          ? const Center(child: Text('Please sign in to manage todos.'))
          : Column(
              children: [
                _buildDateSelector(),
                Expanded(child: _buildTodoList()),
              ],
            ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing: ${_dateLabel(_selectedDate)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return StreamBuilder<List<TodoItemModel>>(
      stream: _todoService.streamTodosForDate(
        userId: _userId!,
        farmId: _farmId!,
        date: _selectedDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load todos: ${snapshot.error}'));
        }

        final todos = snapshot.data ?? [];
        if (todos.isEmpty) {
          return const Center(
            child: Text(
              'No todos for this day.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: CheckboxListTile(
                value: todo.isCompleted,
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  '${_timeLabel(todo.scheduledAt)}${todo.repeatDaily ? ' (Daily)' : ''}\n${todo.description ?? 'No details'}',
                ),
                isThreeLine: true,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }

                  await _todoService.setTodoCompleted(
                    userId: _userId!,
                    farmId: _farmId!,
                    todo: todo,
                    isCompleted: value,
                  );

                  if (value) {
                    await NotificationService.cancelScheduledNotification(
                      todo.notificationId,
                    );
                  } else {
                    await NotificationService.scheduleTodoReminder(
                      notificationId: todo.notificationId,
                      title: 'Todo Reminder',
                      body: todo.title,
                      scheduledAt: todo.scheduledAt,
                      repeatDaily: todo.repeatDaily,
                    );
                  }
                },
                secondary: IconButton(
                  onPressed: () async {
                    await NotificationService.cancelScheduledNotification(
                      todo.notificationId,
                    );
                    await _todoService.deleteTodo(
                      userId: _userId!,
                      farmId: _farmId!,
                      todoId: todo.id,
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddTodoDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool repeatDaily = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Todo'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter title'
                            : null,
                      ),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Time: ${selectedTime.format(dialogContext)}'),
                          TextButton(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedTime = picked;
                                });
                              }
                            },
                            child: const Text('Pick Time'),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        value: repeatDaily,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Repeat daily'),
                        onChanged: (value) {
                          setDialogState(() {
                            repeatDaily = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final scheduledAt = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    final notificationId = DateTime.now().millisecondsSinceEpoch
                        .remainder(2147483646);

                    final todo = TodoItemModel(
                      id: '',
                      title: titleController.text.trim(),
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                      scheduledAt: scheduledAt,
                      isCompleted: false,
                      repeatDaily: repeatDaily,
                      notificationId: notificationId,
                    );

                    await _todoService.addTodo(
                      userId: _userId!,
                      farmId: _farmId!,
                      todo: todo,
                    );

                    await NotificationService.scheduleTodoReminder(
                      notificationId: notificationId,
                      title: 'Todo Reminder',
                      body: todo.title,
                      scheduledAt: scheduledAt,
                      repeatDaily: repeatDaily,
                    );

                    if (!mounted || !dialogContext.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descController.dispose();
  }

  String _dateLabel(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _timeLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
