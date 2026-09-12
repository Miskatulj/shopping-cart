import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/state_views.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _completed;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _completed = widget.task?.completed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.task;
    final task = Task(
      id: existing?.id ?? now.microsecondsSinceEpoch,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      completed: _completed,
      createdAt: existing?.createdAt ?? now,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'Create Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      enabled: !_saving,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        final title = value?.trim() ?? '';
                        if (title.isEmpty) {
                          return 'Please enter a task title.';
                        }
                        if (title.length < 3) {
                          return 'Title must be at least 3 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_saving,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes),
                      ),
                      validator: (value) {
                        final description = value?.trim() ?? '';
                        if (description.isEmpty) {
                          return 'Please describe the task.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _completed,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _completed = value),
                      title: const Text('Completed'),
                      subtitle: const Text('Mark this task as done.'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox.shrink()
                          : Icon(_isEditing ? Icons.save : Icons.add_task),
                      label: _saving
                          ? const LoadingButtonChild(label: 'Saving')
                          : Text(_isEditing ? 'Save Changes' : 'Create Task'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
