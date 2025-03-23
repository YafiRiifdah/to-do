import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'todo_model.dart';
import 'add_task.dart';

class TaskScreen extends StatefulWidget {
  final TodoItem todoItem;
  final Function(TodoItem updatedTodo) onUpdate; // Callback untuk update TodoItem

  const TaskScreen({
    Key? key, 
    required this.todoItem,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  // Daftar subtask
  late List<Map<String, dynamic>> _subtasks;
  
  // Untuk animasi container
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar subtasks dari todoItem jika ada
    _subtasks = widget.todoItem.tasks ?? [];
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Mulai dari bawah layar
      end: Offset.zero, // Bergerak ke posisi asli
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Mulai animasi setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Format tanggal untuk ditampilkan
  String _formatDate(DateTime date) {
    // Format manual tanpa package intl
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // Format time untuk ditampilkan
  String _formatTime(TimeOfDay time) {
    final int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final String minute = time.minute < 10 ? "0${time.minute}" : "${time.minute}";
    final String period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  // Hitung persentase task yang selesai
  double _calculateCompletionPercentage() {
    if (_subtasks.isEmpty) return 0.0;
    
    int completedCount = _subtasks.where((task) => task['completed'] == true).length;
    return completedCount / _subtasks.length;
  }

  // Check jika deadline task sudah terlewat
  bool _isTaskOverdue(Map<String, dynamic> task) {
    if (task['date'] == null) return false;
    
    final DateTime taskDate = task['date'] as DateTime;
    TimeOfDay? taskTime = task['time'] as TimeOfDay?;
    
    final now = DateTime.now();
    
    // Jika tanggal saja sudah lewat, pasti overdue
    if (taskDate.year < now.year || 
        (taskDate.year == now.year && taskDate.month < now.month) ||
        (taskDate.year == now.year && taskDate.month == now.month && taskDate.day < now.day)) {
      return true;
    }
    
    // Jika tanggal sama, periksa waktunya
    if (taskDate.year == now.year && taskDate.month == now.month && taskDate.day == now.day) {
      if (taskTime != null) {
        final nowTimeOfDay = TimeOfDay.fromDateTime(now);
        // Bandingkan jam dan menit
        if (taskTime.hour < nowTimeOfDay.hour || 
            (taskTime.hour == nowTimeOfDay.hour && taskTime.minute < nowTimeOfDay.minute)) {
          return true;
        }
      }
    }
    
    return false;
  }

  // Menghitung berapa hari tersisa atau terlewat
  String _getTimeRemainingText(Map<String, dynamic> task) {
    if (task['date'] == null) return "";
    
    final DateTime taskDate = task['date'] as DateTime;
    final now = DateTime.now();
    
    // Bedakan antara hari ini, besok, dan tanggal lain
    final difference = DateTime(taskDate.year, taskDate.month, taskDate.day)
        .difference(DateTime(now.year, now.month, now.day)).inDays;
    
    if (difference < 0) {
      final days = difference.abs();
      return days == 1 ? "OVERDUE" : "OVERDUE";
    } else if (difference == 0) {
      return "TODAY";
    } else if (difference == 1) {
      return "TOMORROW";
    } else {
      return "DUE IN $difference DAYS";
    }
  }

  // Update TodoItem dan kirim kembali ke parent
  void _updateTodoItem() {
    // Buat objek TodoItem baru dengan nilai yang diperbarui
    final updatedTodo = TodoItem(
      title: widget.todoItem.title,
      isUrgent: widget.todoItem.isUrgent,
      isImportant: widget.todoItem.isImportant,
      taskCount: _subtasks.length, // Update jumlah task
      color: widget.todoItem.color,
      tasks: _subtasks, // Simpan daftar task
    );
    
    // Panggil callback untuk update
    widget.onUpdate(updatedTodo);
  }

  @override
  Widget build(BuildContext context) {
    // Konversi warna yang lebih aman
    Color headerColor;
    if (widget.todoItem.color == "#FC0101") { // Merah
      headerColor = const Color(0xFFFC0101);
    } else if (widget.todoItem.color == "#007BFF") { // Biru
      headerColor = const Color(0xFF007BFF);
    } else if (widget.todoItem.color == "#FFC107") { // Kuning
      headerColor = const Color(0xFFFFC107);
    } else { // Abu-abu atau default
      headerColor = const Color(0xFF808080);
    }
    
    // Warna background aplikasi
    const backgroundColor = Color(0xFFF7F1FE);
    final double completionPercentage = _calculateCompletionPercentage();

    return WillPopScope(
      // Ketika user menavigasi kembali, update TodoItem
      onWillPop: () async {
        _updateTodoItem();
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Header berwarna dengan judul
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    // Header berwarna
                    Container(
                      width: double.infinity,
                      color: headerColor,
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Column(
                        children: [
                          // Bar atas dengan tombol kembali dan menu
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Tombol X di pojok kiri
                                GestureDetector(
                                  onTap: () {
                                    _updateTodoItem(); // Update sebelum pop
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                                ),
                                // Tombol titik tiga di pojok kanan
                                const Icon(Icons.more_horiz, color: Colors.white, size: 28),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Judul Todo (di tengah)
                          Text(
                            widget.todoItem.title,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Progress Bar
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 20, 0), // Kurangi padding atas
                            child: Column(
                              children: [
                                // Linear Progress Indicator
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: completionPercentage,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 10,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Task count and percentage
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${_subtasks.length} ${_subtasks.length == 1 ? 'task' : 'tasks'}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "${(completionPercentage * 100).toInt()}% Completed",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
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
                    
                    // Area konten (hanya untuk warna background)
                    Expanded(
                      child: Container(
                        color: backgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Container yang bergerak ke atas seperti di new_todo.dart
              Positioned(
                top: 188, // Sesuaikan posisi container setelah progress bar
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 25),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20), 
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Daftar subtask di atas tombol
                        if (_subtasks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              children: _subtasks.map((task) => _buildTaskItem(task)).toList(),
                            ),
                          ),
                        
                        // Tombol "Add new Task..." dengan background
                        Container(
                          width: double.infinity,
                          height: 65,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () async {
                                // Navigasi ke halaman AddTaskScreen
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                                );
                                
                                // Jika ada hasil, tambahkan ke daftar subtask
                                if (result != null && result is Map<String, dynamic>) {
                                  setState(() {
                                    _subtasks.add(result);
                                  });
                                  
                                  // Update TodoItem setelah menambahkan task
                                  _updateTodoItem();
                                }
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add, 
                                      color: Colors.blue.shade300,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add New Task...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan item task
  Widget _buildTaskItem(Map<String, dynamic> task) {
    // Cek status overdue
    final bool isOverdue = _isTaskOverdue(task);
    final String timeText = _getTimeRemainingText(task);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris pertama dengan checkbox, judul task, dan status deadline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 3),
                child: Checkbox(
                  value: task['completed'] ?? false,
                  shape: const CircleBorder(),
                  onChanged: (value) {
                    setState(() {
                      task['completed'] = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Task title and notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      task['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task['completed'] == true
                            ? TextDecoration.lineThrough
                            : null,
                        color: task['completed'] == true
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    
                    // Notes jika ada
                    if (task['notes'] != null && task['notes'].toString().isNotEmpty)
                      Text(
                        task['notes'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Status deadline - ditampilkan secara horizontal dengan latar belakang sesuai status
              if (timeText.isNotEmpty && !task['completed'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? Colors.red : Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          
          // Baris kedua untuk deadline & reminder MENJALAR KE BAWAH (VERTIKAL)
          if (task['date'] != null || task['time'] != null || task['reminder'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 36.0),
              child: Column(  // Menggunakan Column agar widget menjalar ke bawah
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deadline dengan icon kalender
                  if (task['date'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6.0),  // Margin bawah
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,  // Minimalisasi ukuran row
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            task['time'] != null
                                ? "${_formatDate(task['date'])}, ${_formatTime(task['time'])}"
                                : _formatDate(task['date']),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Reminder dengan icon bell
                  if (task['reminder'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,  // Minimalisasi ukuran row
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            task['time'] != null ? _formatTime(task['time']) : 'Reminder',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}