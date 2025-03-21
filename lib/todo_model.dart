class TodoItem {
  final String title;
  final bool isUrgent;
  final bool isImportant;
  final int taskCount;
  final String color; // Untuk warna card berdasarkan prioritas

  TodoItem({
    required this.title,
    required this.isUrgent,
    required this.isImportant,
    this.taskCount = 0,
    required this.color,
  });
}