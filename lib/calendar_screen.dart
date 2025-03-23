import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedMonth;
  late DateTime _focusedDay;
  
  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _focusedDay = DateTime.now();
  }
  
  // Go to previous month
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }
  
  // Go to next month
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }
  
  // Metode untuk navigasi antar halaman
  void _navigateToPage(String page) {
    if (page == 'To Do') {
      Navigator.pop(context); // Kembali ke halaman sebelumnya (to_do.dart)
    }
    // Tambahkan navigasi untuk halaman lain jika diperlukan (Focus, Done!, Setting)
  }
  
  // Get days in the selected month
  List<DateTime> _getDaysInMonth() {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday % 7; // 0 is Sunday, 1 is Monday, etc.
    
    // Create a list for the preceding days (from previous month)
    final previousMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    final daysInPreviousMonth = DateUtils.getDaysInMonth(previousMonth.year, previousMonth.month);
    
    List<DateTime> days = [];
    
    // Add days from previous month to fill the start of the calendar grid
    for (int i = 0; i < firstDayWeekday; i++) {
      days.add(DateTime(previousMonth.year, previousMonth.month, daysInPreviousMonth - firstDayWeekday + i + 1));
    }
    
    // Add days from current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_selectedMonth.year, _selectedMonth.month, i));
    }
    
    // Add days from next month to fill the end of the calendar grid if needed
    final remainingDays = 42 - days.length; // 6 weeks × 7 days = 42 total cells
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }
    
    return days;
  }
  
  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final monthFormat = DateFormat('MMMM, yyyy');
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      body: Column(
        children: [
          // Calendar container with background image
          Expanded(
            child: Column(
              children: [
                // Calendar layout with full-width white background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background PNG image - ditempatkan di pojok kanan
                      Positioned(
                        top: 70, // Posisi lebih dekat ke atas
                        right: 20, // Lebih dekat ke kanan
                        width: 160, // Ukuran gambar diperkecil lagi
                        height: 160, // Ukuran gambar diperkecil lagi
                        child: Image.asset(
                          'assets/kalender.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Calendar content
                      Column(
                        children: [
                          // Spacer untuk status bar
                          const SizedBox(height: 40),
                          
                          // Month and year display
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left arrow and Month name in left
                                Row(
                                  children: [
                                    // Left arrow
                                    GestureDetector(
                                      onTap: _previousMonth,
                                      child: const Icon(Icons.chevron_left, size: 24),
                                    ),
                                    
                                    // Month name
                                    Text(
                                      monthFormat.format(_selectedMonth),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    
                                    // Right arrow
                                    GestureDetector(
                                      onTap: _nextMonth,
                                      child: const Icon(Icons.chevron_right, size: 24),
                                    ),
                                  ],
                                ),
                                
                                // Placeholder to maintain layout balance
                                const SizedBox(width: 24),
                              ],
                            ),
                          ),
                          
                          // Day labels (Sun, Mon, etc.)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                  .map((day) => SizedBox(
                                        width: 40,
                                        child: Text(
                                          day,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10, // Ukuran font diperkecil
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Calendar days grid
                          Container(
                            height: 170, // Ukuran kalender diperkecil lagi
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 2, // Jarak vertikal diperkecil lagi
                                crossAxisSpacing: 2, // Jarak horizontal diperkecil lagi
                                childAspectRatio: 1.5, // Membuat sel lebih lebar lagi
                              ),
                              itemCount: days.length,
                              itemBuilder: (context, index) {
                                final day = days[index];
                                final isCurrentMonth = day.month == _selectedMonth.month;
                                final isToday = day.year == DateTime.now().year &&
                                    day.month == DateTime.now().month &&
                                    day.day == DateTime.now().day;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _focusedDay = day;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday 
                                        ? Colors.blue[100] 
                                        : _focusedDay.year == day.year && 
                                          _focusedDay.month == day.month && 
                                          _focusedDay.day == day.day
                                          ? Colors.grey[200] // Background abu-abu untuk tanggal yang dipilih
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                      border: _focusedDay.year == day.year && 
                                             _focusedDay.month == day.month && 
                                             _focusedDay.day == day.day
                                         ? Border.all(color: Colors.grey[400]!, width: 1) // Border abu-abu untuk tanggal yang dipilih
                                         : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        day.day.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12, // Ukuran font diperbesar
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                          color: isCurrentMonth 
                                            ? isToday 
                                              ? Colors.blue[800] 
                                              : _focusedDay.year == day.year && 
                                                _focusedDay.month == day.month && 
                                                _focusedDay.day == day.day
                                                ? Colors.grey[700] // Tanggal yang diklik menjadi abu-abu
                                                : Colors.black
                                            : Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Empty state message - now separate from the calendar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'There are no scheduled tasks.',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6A6A6A),
                            ),
                          ),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                _buildNavItem(Icons.view_list_rounded, 'To Do', onTap: () => _navigateToPage('To Do')),
                _buildNavItem(Icons.calendar_today_outlined, 'Date', isSelected: true),
                _buildNavItem(Icons.check_circle_outline, 'Done!', onTap: () => _navigateToPage('Done')),
                _buildNavItem(Icons.settings_outlined, 'Setting', onTap: () => _navigateToPage('Setting')),
              ],
            ),
          ),
        ],
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