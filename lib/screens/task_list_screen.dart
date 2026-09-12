import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_api_service.dart';
import '../widgets/state_views.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.apiService});

  final TaskApiService? apiService;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskApiService _apiService;
  final List<Task> _tasks = [];
  bool _loading = true;
  bool _busy = false;
  String? _errorMessage;

  List<Task> get _completedTasks =>
      _tasks.where((task) => task.completed).toList();
  List<Task> get _pendingTasks =>
      _tasks.where((task) => !task.completed).toList();

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? TaskApiService();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _apiService.fetchTasks();
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(tasks);
      });
    } on TaskApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshTasks() async {
    try {
      final tasks = await _apiService.fetchTasks();
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
        _tasks
          ..clear()
          ..addAll(tasks);
      });
      _showMessage('Tasks refreshed.');
    } on TaskApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    }
  }

  Future<void> _openCreateTask() async {
    final task = await Navigator.of(context)
        .push<Task>(MaterialPageRoute(builder: (_) => const TaskFormScreen()));
    if (task == null) return;

    await _runAction(
      successMessage: 'Task created successfully.',
      action: () async {
        final created = await _apiService.createTask(task);
        setState(() => _tasks.insert(0, created));
      },
    );
  }

  Future<void> _openEditTask(Task task) async {
    final updatedTask = await Navigator.of(
      context,
    ).push<Task>(MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)));
    if (updatedTask == null) return;

    await _saveUpdatedTask(
      updatedTask,
      successMessage: 'Task updated successfully.',
    );
  }

  Future<void> _toggleCompleted(Task task, bool completed) async {
    await _saveUpdatedTask(
      task.copyWith(completed: completed),
      successMessage: completed
          ? 'Task marked completed.'
          : 'Task marked pending.',
    );
  }

  Future<void> _saveUpdatedTask(
    Task task, {
    required String successMessage,
  }) async {
    await _runAction(
      successMessage: successMessage,
      action: () async {
        final updated = await _apiService.updateTask(task);
        final index = _tasks.indexWhere((item) => item.id == updated.id);
        if (index != -1) {
          setState(() => _tasks[index] = updated);
        }
      },
    );
  }

  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently remove "${task.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await _runAction(
      successMessage: 'Task deleted.',
      action: () async {
        await _apiService.deleteTask(task.id);
        setState(() => _tasks.removeWhere((item) => item.id == task.id));
      },
    );
  }

  Future<void> _runAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await action();
      if (!mounted) return;
      _showMessage(successMessage);
    } on TaskApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : const Color(0xFF2E7D32),
      ),
    );
  }

  void _openDetails(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onEdit: () {
            Navigator.of(context).pop();
            _openEditTask(task);
          },
          onDelete: () {
            Navigator.of(context).pop();
            _confirmDelete(task);
          },
          onToggleCompleted: (value) {
            Navigator.of(context).pop();
            _toggleCompleted(task, value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
        ? ErrorStateView(message: _errorMessage!, onRetry: _loadTasks)
        : _tasks.isEmpty
        ? EmptyStateView(onCreate: _openCreateTask)
        : RefreshIndicator(
            onRefresh: _refreshTasks,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _SummaryHeader(
                  total: _tasks.length,
                  pending: _pendingTasks.length,
                  completed: _completedTasks.length,
                ),
                const SizedBox(height: 16),
                ..._tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TaskCard(
                      task: task,
                      busy: _busy,
                      onTap: () => _openDetails(task),
                      onEdit: () => _openEditTask(task),
                      onDelete: () => _confirmDelete(task),
                      onToggleCompleted: (value) =>
                          _toggleCompleted(task, value),
                    ),
                  ),
                ),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            tooltip: 'Refresh tasks',
            onPressed: _loading || _busy ? null : _refreshTasks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(child: body),
          if (_busy)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _openCreateTask,
        icon: const Icon(Icons.add_task),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.total,
    required this.pending,
    required this.completed,
  });

  final int total;
  final int pending;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final cards = [
          _SummaryCard(
            label: 'Total',
            value: total,
            icon: Icons.list_alt,
            color: Theme.of(context).colorScheme.primary,
          ),
          _SummaryCard(
            label: 'Pending',
            value: pending,
            icon: Icons.pending_actions,
            color: const Color(0xFFF57C00),
          ),
          _SummaryCard(
            label: 'Completed',
            value: completed,
            icon: Icons.verified_outlined,
            color: const Color(0xFF2E7D32),
          ),
        ];

        if (compact) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$value',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.busy,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompleted,
  });

  final Task task;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Checkbox(
                value: task.completed,
                onChanged: busy
                    ? null
                    : (value) => onToggleCompleted(value ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description.isEmpty
                          ? 'No description'
                          : task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                enabled: !busy,
                tooltip: 'Task actions',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
