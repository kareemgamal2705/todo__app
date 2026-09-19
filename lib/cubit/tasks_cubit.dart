import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/task_model.dart';
import '../features/firebase_helper.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;
  TasksLoaded(this.tasks);
}

class TasksError extends TaskState {
  final String message;
  TasksError(this.message);
}

class TasksCubit extends Cubit<TaskState> {
  StreamSubscription? _tasksSubscription;

  TasksCubit() : super(TaskInitial()) {
    _listenToTasks();
  }

  void _listenToTasks() {
    _tasksSubscription = FirebaseHelper.getTasksStream().listen((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TaskModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isDone: data['isDone'] ?? false,
        );
      }).toList();

      emit(TasksLoaded(tasks));
    }, onError: (e) => emit(TasksError(e.toString())));
  }

  Future<void> addTask(String title, String description, DateTime date) {
    return FirebaseHelper.addTask(
      title: title,
      description: description,
      time: date,
    );
  }

  Future<void> editTask(
    String id,
    String title,
    String description,
    DateTime date,
  ) {
    return FirebaseHelper.editTask(
      docId: id,
      title: title,
      description: description,
      time: date,
    );
  }

  Future<void> deleteTask(String id) {
    return FirebaseHelper.deleteTask(id);
  }

  Future<void> toggleTaskStatus(String id, bool isDone) {
    return FirebaseHelper.updateTaskStatus(id, isDone);
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
