import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'todo_model.dart';
import 'add_task.dart';

class TaskScreen extends StatefulWidget {
  final TodoItem todoItem;

  const TaskScreen({Key? key, required this.todoItem}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  // Daftar subtask (kosong pada awalnya)
  final List<Map<String, dynamic>> _subtasks = [];
  
  // Untuk animasi container - hilangkan kata kunci 'late'
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi secara langsung
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Mulai dari bawah layar
      end: Offset.zero, // Bergerak ke posisi asli
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));
    
    // Mulai animasi setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController!.forward();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Konversi string hex ke color untuk header
    final headerColor = Color(int.parse(widget.todoItem.color.replaceAll('#', '0xFF')));
    // Warna background aplikasi
    const backgroundColor = Color(0xFFF7F1FE);

    return Scaffold(
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
                  // Header merah
                  Container(
                    width: double.infinity,
                    color: headerColor,
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20), // Menghapus padding horizontal untuk ikon ke pojok
                    child: Column(
                      children: [
                        // Bar atas dengan tombol kembali dan menu - dengan padding yang lebih sedikit
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tombol X di pojok kiri - tanpa padding tambahan
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.close, color: Colors.white, size: 28),
                              ),
                              // Tombol titik tiga di pojok kanan
                              const Icon(Icons.more_horiz, color: Colors.white, size: 28),
                            ],
                          ),
                        ),
                        
                        // Spasi untuk menempatkan judul di bagian tengah header
                        const SizedBox(height: 30), // Mengurangi space agar judul naik ke atas
                        
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
                        
                        const SizedBox(height: 40), // Tetap mempertahankan space di bawah judul
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
            if (_slideAnimation != null)
              Positioned(
                top: 170, // Mempertahankan posisi container
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 25), // Mengurangi padding atas menjadi 5
                    decoration: BoxDecoration(
                      color: backgroundColor, // Menggunakan warna background yang sama
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
                        // Menghilangkan space di atas tombol
                        const SizedBox(height: 0), // Dihilangkan
                        
                        // Tombol "Add new Task..." dengan background dan ukuran yang lebih besar
                        Container(
                          width: double.infinity, // Memastikan tombol menggunakan lebar penuh
                          height: 65, // Tinggi tombol yang lebih besar lagi (dari 55 menjadi 65)
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6), // Sudut kurang melengkung
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
                            child: InkWell(
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
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.add, 
                                      color: Color(0xFF8D8D8D), // Warna ikon abu-abu
                                      size: 23, // Ukuran ikon
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Add new Task...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15, // Font size
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF77A4F6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Daftar subtask di bawah tombol
                        if (_subtasks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              children: _subtasks.map((task) => _buildTaskItem(task)).toList(),
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
    );
  }

  // Widget untuk menampilkan item task
  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task['completed'] ?? false,
            onChanged: (value) {
              setState(() {
                task['completed'] = value;
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task['title'],
              style: GoogleFonts.poppins(
                decoration: task['completed'] == true
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}