import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'todo_model.dart';

// Kelas EditTodoScreen yang mewarisi dari StatefulWidget
class EditTodoScreen extends StatefulWidget {
  final TodoItem todoToEdit;
  
  const EditTodoScreen({Key? key, required this.todoToEdit}) : super(key: key);

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  // Controller untuk input teks
  late TextEditingController _titleController;
  
  // Track button states
  late bool isUrgentlySelected;
  late bool isNotUrgentlySelected;
  late bool isImportantSelected;
  late bool isNotImportantSelected;
  
  // Track if title is empty
  bool isTitleEmpty = false;

  @override
  void initState() {
    super.initState();
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
    
    // Initialize controllers and states from todoToEdit
    _titleController = TextEditingController(text: widget.todoToEdit.title);
    
    // Initialize button states based on todoToEdit
    isUrgentlySelected = widget.todoToEdit.isUrgent;
    isNotUrgentlySelected = !widget.todoToEdit.isUrgent;
    isImportantSelected = widget.todoToEdit.isImportant;
    isNotImportantSelected = !widget.todoToEdit.isImportant;
    
    // Mulai animasi setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
    
    // Tambahkan listener pada text controller untuk mengubah warna tombol
    _titleController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final newIsTitleEmpty = _titleController.text.trim().isEmpty;
    if (newIsTitleEmpty != isTitleEmpty) {
      setState(() {
        isTitleEmpty = newIsTitleEmpty;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Fungsi untuk mendapatkan warna berdasarkan prioritas sesuai spesifikasi
  String _getCardColor() {
    // Jika user memilih "Urgently" DAN "Important" - Warna MERAH
    if (isUrgentlySelected && isImportantSelected) {
      return "#FC0101"; // Merah
    } 
    // Jika user memilih "Not Urgently" DAN "Not Important" - Warna BIRU
    else if (isNotUrgentlySelected && isNotImportantSelected) {
      return "#007BFF"; // Biru
    }
    // Jika user memilih "Urgently" dan "Not Important" ATAU "Not Urgently" dan "Important" - Warna KUNING
    else if ((isUrgentlySelected && isNotImportantSelected) || 
             (isNotUrgentlySelected && isImportantSelected)) {
      return "#FFC107"; // Kuning
    }
    // Jika hanya satu yang dipilih atau tidak ada yang dipilih
    else if (isUrgentlySelected) {
      return "#FC0101"; // Merah
    }
    else if (isImportantSelected) {
      return "#FC0101"; // Merah
    }
    else if (isNotUrgentlySelected) {
      return "#007BFF"; // Biru
    }
    else if (isNotImportantSelected) {
      return "#007BFF"; // Biru
    }
    // Default jika tidak ada yang dipilih - Warna ABU-ABU
    else {
      return "#808080"; // Abu-abu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      // Ini akan membantu konten untuk tidak digeser oleh keyboard
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit To Do',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              margin: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  // Mengecek apakah judul sudah diisi
                  if (_titleController.text.trim().isNotEmpty) {
                    // Membuat objek TodoItem baru dengan menggunakan method copyWith
                    final updatedTodo = widget.todoToEdit.copyWith(
                      title: _titleController.text.trim(),
                      isUrgent: isUrgentlySelected,
                      isImportant: isImportantSelected,
                      color: _getCardColor(),
                      // Kita tidak perlu mengubah taskCount atau tasks
                    );
                    
                    // Kembali ke halaman sebelumnya dengan data yang diperbarui
                    Navigator.pop(context, updatedTodo);
                  } else {
                    // Menampilkan pesan jika judul kosong
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a title for your task'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  // Warna selalu hijau karena dalam mode edit, judul selalu ada
                  backgroundColor: isTitleEmpty ? Colors.grey.shade400 : Colors.green,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(50, 26), // Tombol lebih kecil
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Warna font putih
                    fontWeight: FontWeight.w500,
                    fontSize: 12, // Ukuran font lebih kecil
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input field untuk judul todo dengan TextField
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextField(
                controller: _titleController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'To Do title...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Gunakan Expanded agar container dapat menyesuaikan ukuran
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prioritize',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Urgently row with colored buttons
                    Row(
                      children: [
                        _buildPriorityButton(
                          'Urgently', 
                          isUrgentlySelected,
                          const Color(0xFFFC0101),
                          () {
                            setState(() {
                              isUrgentlySelected = !isUrgentlySelected;
                              if (isUrgentlySelected) {
                                isNotUrgentlySelected = false;
                              }
                            });
                          }
                        ),
                        const SizedBox(width: 10),
                        _buildPriorityButton(
                          'Not urgently', 
                          isNotUrgentlySelected,
                          const Color(0xFF007BFF),
                          () {
                            setState(() {
                              isNotUrgentlySelected = !isNotUrgentlySelected;
                              if (isNotUrgentlySelected) {
                                isUrgentlySelected = false;
                              }
                            });
                          }
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Divider
                    const Divider(thickness: 1),
                    
                    const SizedBox(height: 12),
                    
                    // Important row with colored buttons
                    Row(
                      children: [
                        _buildPriorityButton(
                          'Important', 
                          isImportantSelected,
                          const Color(0xFFFC0101),
                          () {
                            setState(() {
                              isImportantSelected = !isImportantSelected;
                              if (isImportantSelected) {
                                isNotImportantSelected = false;
                              }
                            });
                          }
                        ),
                        const SizedBox(width: 10),
                        _buildPriorityButton(
                          'Not important', 
                          isNotImportantSelected,
                          const Color(0xFF007BFF),
                          () {
                            setState(() {
                              isNotImportantSelected = !isNotImportantSelected;
                              if (isNotImportantSelected) {
                                isImportantSelected = false;
                              }
                            });
                          }
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityButton(String label, bool isSelected, Color activeColor, VoidCallback onPressed) {
    return Expanded(
      child: SizedBox(
        height: 36, // Tombol lebih kecil
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? activeColor : Colors.grey.shade400, // Warna tombol berubah saat dipilih
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded yang lebih kecil
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12, // Ukuran teks lebih kecil
              fontWeight: FontWeight.bold, // Font di-bold
              color: Colors.white, // Warna teks putih
            ),
          ),
        ),
      ),
    );
  }
}