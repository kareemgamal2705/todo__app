class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isDone;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isDone = false,
  });

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? isDone,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          date == other.date &&
          isDone == other.isDone;

  @override
  int get hashCode => Object.hash(id, title, description, date, isDone);
}
