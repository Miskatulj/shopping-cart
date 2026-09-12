class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawTitle = json['title'] ?? json['name'] ?? 'Untitled task';
    final rawDescription = json['description'] ?? json['body'] ?? '';
    final rawCompleted = json['completed'] ?? json['isCompleted'] ?? false;
    final rawCreatedAt = json['createdAt'];

    return Task(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      title: '$rawTitle',
      description: '$rawDescription',
      completed: rawCompleted == true || rawCompleted == 1,
      createdAt: rawCreatedAt is String
          ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
