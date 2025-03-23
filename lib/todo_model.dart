class TodoItem {
  final String title;
  final bool isUrgent;
  final bool isImportant;
  final int taskCount;
  final String color;
  final List<Map<String, dynamic>>? tasks; // Property untuk menyimpan daftar task

  TodoItem({
    required this.title,
    required this.isUrgent,
    required this.isImportant,
    required this.taskCount,
    required this.color,
    this.tasks, // Opsional, bisa null saat pertama kali dibuat
  });

  // Method untuk membuat salinan dengan nilai yang diperbaharui
  TodoItem copyWith({
    String? title,
    bool? isUrgent,
    bool? isImportant,
    int? taskCount,
    String? color,
    List<Map<String, dynamic>>? tasks,
  }) {
    return TodoItem(
      title: title ?? this.title,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      taskCount: taskCount ?? this.taskCount,
      color: color ?? this.color,
      tasks: tasks ?? this.tasks,
    );
  }
}