import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/task_model.dart';
import '../../features/firebase_helper.dart';
import '../../cubit/tasks_cubit.dart';
import '../../widgets/status_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryTeal.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          backgroundColor: primaryTeal,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              Expanded(child: _buildTasksList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workspace',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Best platform for creating to-do lists',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Log out',
              icon: const Icon(Icons.logout, color: Colors.grey, size: 24),
              onPressed: () async {
                final router = GoRouter.of(context);
                await FirebaseHelper.signOut();
                if (!mounted) return;
                router.go('/auth-options');
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.grey, size: 28),
              onPressed: () async {
                await context.push('/choose-theme');
                if (context.mounted) setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return BlocBuilder<TasksCubit, TaskState>(
      buildWhen: (previous, current) {
        if (previous is TasksLoaded && current is TasksLoaded) {
          return !listEquals(previous.tasks, current.tasks);
        }
        return true;
      },
      builder: (context, state) {
        if (state is TaskInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TasksError) {
          return Center(
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: redAccent),
            ),
          );
        }

        final tasks = (state as TasksLoaded).tasks;

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryTeal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, color: white, size: 20),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Tap plus to create a new task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add your task',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return GestureDetector(
      onLongPress: () => _showEditTaskDialog(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 25,
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: task.isDone,
                        activeColor: primaryTeal,
                        onChanged: (value) async {
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          try {
                            await context.read<TasksCubit>().toggleTaskStatus(
                              task.id,
                              value!,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            messenger?.showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: redAccent,
                        ),
                        onPressed: () => _confirmDeleteTask(task),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 45.0),
                    child: Text(
                      task.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Long press to edit',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatDate(task.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final cubit = context.read<TasksCubit>();
              runWithStatusDialog(
                context,
                () => cubit.deleteTask(task.id),
                loadingMessage: 'Deleting task...',
                successMessage: 'Task deleted',
              );
            },
            child: const Text('Delete', style: TextStyle(color: redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddTaskDialog(parentContext: context),
    );
  }

  void _showEditTaskDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => _EditTaskDialog(parentContext: context, task: task),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, index: 0),
          _buildNavItem(icon: Icons.calendar_today_outlined, index: 1),
          const SizedBox(width: 50),
          _buildNavItem(icon: Icons.person_outline, index: 2),
          _buildNavItem(icon: Icons.history, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    bool isSelected = _bottomNavIndex == index;
    return IconButton(
      onPressed: () => setState(() => _bottomNavIndex = index),
      icon: Icon(icon, color: isSelected ? black : black54, size: 28),
    );
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String weekday = days[date.weekday - 1];
    String month = months[date.month - 1];
    DateTime now = DateTime.now();
    bool isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    return "${isToday ? 'Today . ' : ''}$weekday ${date.day} $month ${date.year}";
  }
}

class _TaskForm extends StatefulWidget {
  final String initialTitle;
  final String initialDescription;
  final DateTime initialDate;
  final String submitLabel;
  final void Function(String title, String description, DateTime date) onSubmit;

  const _TaskForm({
    required this.initialTitle,
    required this.initialDescription,
    required this.initialDate,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descController = TextEditingController(text: widget.initialDescription);
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: white,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'eg: Meeting with client',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryTeal,
                    onPrimary: white,
                    onSurface: black,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  currentDate: _selectedDate,
                  onDateChanged: (newDate) =>
                      setState(() => _selectedDate = newDate),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;
                  widget.onSubmit(
                    _titleController.text.trim(),
                    _descController.text.trim(),
                    _selectedDate,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.submitLabel,
                  style: const TextStyle(color: white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTaskDialog extends StatelessWidget {
  final BuildContext parentContext;
  const _AddTaskDialog({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return _TaskForm(
      initialTitle: '',
      initialDescription: '',
      initialDate: DateTime.now(),
      submitLabel: 'Create Task',
      onSubmit: (title, description, date) {
        final cubit = parentContext.read<TasksCubit>();
        Navigator.pop(context);
        runWithStatusDialog(
          parentContext,
          () => cubit.addTask(title, description, date),
          loadingMessage: 'Adding task...',
          successMessage: 'Task added successfully',
        );
      },
    );
  }
}

class _EditTaskDialog extends StatelessWidget {
  final BuildContext parentContext;
  final TaskModel task;
  const _EditTaskDialog({required this.parentContext, required this.task});

  @override
  Widget build(BuildContext context) {
    return _TaskForm(
      initialTitle: task.title,
      initialDescription: task.description,
      initialDate: task.date,
      submitLabel: 'Save Changes',
      onSubmit: (title, description, date) {
        final cubit = parentContext.read<TasksCubit>();
        Navigator.pop(context);
        runWithStatusDialog(
          parentContext,
          () => cubit.editTask(task.id, title, description, date),
          loadingMessage: 'Saving changes...',
          successMessage: 'Task updated successfully',
        );
      },
    );
  }
}
