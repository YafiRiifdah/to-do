import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_todo.dart';
import 'todo_model.dart';
import 'task.dart';
import 'edit_todo.dart';
import 'calendar_screen.dart'; // Import the calendar screen

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Daftar untuk menyimpan semua tugas
  final List<TodoItem> _todos = [];
  
  // Method untuk memperbarui TodoItem
  void _updateTodoItem(TodoItem updatedTodo) {
    setState(() {
      final index = _todos.indexWhere(
        (item) => item.title == updatedTodo.title,
      );
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
    });
  }

  // Metode untuk mengedit todo
  void _editTodo(TodoItem todo) async {
    // Navigasi ke halaman EditTodoScreen untuk mode edit
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTodoScreen(todoToEdit: todo)),
    );

    // Jika ada hasil (todo yang diedit), update di daftar
    if (result != null && result is TodoItem) {
      setState(() {
        final index = _todos.indexWhere((item) => item.title == todo.title);
        if (index != -1) {
          _todos[index] = result;
        }
      });
    }
  }

  // Metode untuk menghapus todo
  void _deleteTodo(TodoItem todo) {
    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Todo'),
            content: Text('Are you sure you want to delete "${todo.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancel
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Hapus todo dari list
                  setState(() {
                    _todos.removeWhere((item) => item.title == todo.title);
                  });
                  Navigator.pop(context); // Tutup dialog
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
  
  // Method untuk navigasi ke berbagai halaman sesuai dengan item navbar yang dipilih
  void _navigateToPage(String page) {
    if (page == 'Date') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    }
    // Tambahkan navigasi untuk halaman lain di sini (Focus, Done!, Setting)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan judul dan tombol tambah
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'To Do',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Icon plus dengan navigasi ke halaman baru
                  InkWell(
                    onTap: () async {
                      // Navigasi ke halaman New Todo dan tunggu hasil
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewTodoScreen(),
                        ),
                      );

                      // Jika ada hasil (todo baru), tambahkan ke daftar
                      if (result != null && result is TodoItem) {
                        setState(() {
                          // Pastikan task list kosong saat pertama kali dibuat
                          final newTodo = TodoItem(
                            title: result.title,
                            isUrgent: result.isUrgent,
                            isImportant: result.isImportant,
                            taskCount: 0, // Mulai dari 0
                            color: result.color,
                            tasks: [], // Inisialisasi dengan array kosong
                          );
                          _todos.add(newTodo);
                        });
                      }
                    },
                    child: const Icon(Icons.add, size: 30, weight: 700),
                  ),
                ],
              ),
            ),

            // Konten utama - Tampilkan daftar todo atau gambar placeholder
            Expanded(
              child:
                  _todos.isEmpty
                      ? _buildEmptyState() // Tampilkan gambar placeholder jika tidak ada todo
                      : _buildTodoList(), // Tampilkan daftar todo jika ada
            ),

            // Bottom navigation bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.access_time_rounded, 'Focus', onTap: () => _navigateToPage('Focus')),
                  _buildNavItem(
                    Icons.view_list_rounded,
                    'To Do',
                    isSelected: true,
                  ),
                  _buildNavItem(Icons.calendar_today_outlined, 'Date', onTap: () => _navigateToPage('Date')),
                  _buildNavItem(Icons.check_circle_outline, 'Done!', onTap: () => _navigateToPage('Done')),
                  _buildNavItem(Icons.settings_outlined, 'Setting', onTap: () => _navigateToPage('Setting')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan gambar placeholder saat tidak ada tugas
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gambar dari assets
        Image.asset(
          'assets/1.png',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),

        // Text "There are no scheduled tasks"
        Text(
          'There are no scheduled tasks.',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6A6A6A),
          ),
        ),

        // Subtext
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
          child: Text(
            'Create a new task or activity to ensure it is always scheduled.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF6A6A6A),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan daftar tugas
  Widget _buildTodoList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 card per baris
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1, // Card berbentuk persegi
        ),
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];

          // Konversi warna dengan cara yang lebih aman
          Color cardColor;
          if (todo.color == "#FC0101") {
            // Merah
            cardColor = const Color(0xFFFC0101);
          } else if (todo.color == "#007BFF") {
            // Biru
            cardColor = const Color(0xFF007BFF);
          } else if (todo.color == "#FFC107") {
            // Kuning
            cardColor = const Color(0xFFFFC107);
          } else {
            // Abu-abu atau default
            cardColor = const Color(0xFF808080);
          }

          return GestureDetector(
            onTap: () async {
              // Navigasi ke halaman Task ketika card ditekan dan tunggu hasil update
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TaskScreen(
                        todoItem: todo,
                        onUpdate: _updateTodoItem, // Callback untuk update
                      ),
                ),
              );
            },
            child: Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Konten utama kartu
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),

                        // Judul todo
                        Text(
                          todo.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Jumlah task - menampilkan jumlah task yang telah ditambahkan
                        Text(
                          '${todo.taskCount} ${todo.taskCount == 1 ? 'task' : 'tasks'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu titik tiga dengan popup (diposisikan di bagian atas kanan)
                  Positioned(
                    top: 0, // Mengubah nilai top menjadi 0 (paling atas)
                    right: 0, // Mengubah nilai right menjadi 0 (paling kanan)
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 24, // Mengatur ukuran ikon agar konsisten
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onSelected: (String choice) {
                        if (choice == 'Edit') {
                          // Handle edit action
                          _editTodo(todo);
                        } else if (choice == 'Delete') {
                          // Handle delete action
                          _deleteTodo(todo);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'Edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ];
                      },
                      // Pastikan popup tetap kontras dengan background kartu
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}