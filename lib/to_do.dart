import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_todo.dart';
import 'todo_model.dart';
import 'task.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Daftar untuk menyimpan semua tugas
  final List<TodoItem> _todos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE), // Warna latar belakang sesuai permintaan
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan judul dan tombol tambah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
                        MaterialPageRoute(builder: (context) => const NewTodoScreen()),
                      );
                      
                      // Jika ada hasil (todo baru), tambahkan ke daftar
                      if (result != null && result is TodoItem) {
                        setState(() {
                          _todos.add(result);
                        });
                      }
                    },
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      weight: 700,
                    ),
                  ),
                ],
              ),
            ),
            
            // Konten utama - Tampilkan daftar todo atau gambar placeholder
            Expanded(
              child: _todos.isEmpty
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
                  _buildNavItem(Icons.access_time_rounded, 'Focus'),
                  _buildNavItem(Icons.view_list_rounded, 'To Do', isSelected: true),
                  _buildNavItem(Icons.calendar_today_outlined, 'Date'),
                  _buildNavItem(Icons.check_circle_outline, 'Done!'),
                  _buildNavItem(Icons.settings_outlined, 'Setting'),
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
          // Konversi string hex ke color
          final cardColor = Color(int.parse(todo.color.replaceAll('#', '0xFF')));
          
          return GestureDetector(
            onTap: () {
              // Navigasi ke halaman Task ketika card ditekan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskScreen(todoItem: todo),
                ),
              );
            },
            child: Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded yang lebih kecil
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu titik tiga
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    
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
                    
                    // Jumlah task
                    Text(
                      '${todo.taskCount} task',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}