import 'package:flutter/material.dart';
import 'signin.dart'; // Để đăng xuất
import 'package:firebase_auth/firebase_auth.dart'; // Nếu dùng Firebase

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Quản lý tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Thêm logic điều hướng hoặc hiển thị nội dung
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

       @override
      Widget build(BuildContext context) {
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF4285F4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vũ Minh Quân',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.class_, color: Color(0xFF4285F4), size: 24),
                  title: const Text('Lớp học', style: TextStyle(fontSize: 16)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF4285F4), size: 24),
                  title: const Text('Lịch', style: TextStyle(fontSize: 16)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.assignment, color: Color(0xFF4285F4), size: 24),
                  title: const Text('Bài tập', style: TextStyle(fontSize: 16)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Color(0xFF4285F4), size: 24),
                  title: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              // Background dưới cùng
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8BC34A), Color(0xFFFFFFFF)], // Olive nhạt sang trắng
                      stops: [0.0, 0.8],
                    ),
                  ),
                ),
              ),
              // Header (AppBar) nằm giữa
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25, // 25% chiều cao màn hình
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color.fromARGB(255, 78, 26, 126), Color.fromARGB(255, 192, 154, 223)], // Gradient navy sang xanh nhạt
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40000000), // Bóng mờ
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)), // Bo góc dưới
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Builder(
                        builder: (context) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer(); // Mở drawer với context đúng
                                  },
                                ),
                                const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                'School Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                                IconButton(
                                  icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Notifications clicked!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Class Flutter',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Vũ Minh Quân',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.green[300],
                                    child: const Text('V', style: TextStyle(color: Colors.white, fontSize: 20)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Body (các khung) nằm trên header, vị trí cố định
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15, // Bắt đầu ngay dưới header (15% chiều cao)
                left: MediaQuery.of(context).size.width * 0.05, // 5% lề trái
                right: MediaQuery.of(context).size.width * 0.05, // 5% lề phải
                bottom: MediaQuery.of(context).size.height * 0.075, // 7,5% từ dưới cùng
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.book, color: Colors.orange, size: 40),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'What’s next',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Geometric weekly test',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            '2 days to go',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_circle_filled, color: Colors.blue, size: 40),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Next Class',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Geometric Video Class',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            'in 20-59 min',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0.0),
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                                children: [
                                  _buildGridTile('Syllabus', 'What to learn', Colors.blue[300]!, Icons.book),
                                  _buildGridTile('Calendar', 'View schedule', Colors.purple[300]!, Icons.calendar_today),
                                  _buildGridTile('Tests', 'What to learn', Colors.orange[300]!, Icons.quiz),
                                  _buildGridTile('Insights', 'Performance', Colors.pink[300]!, Icons.analytics),
                                  _buildGridTile('Faculty', 'List of teachers', Colors.green[300]!, Icons.school),
                                  _buildGridTile('Messages', 'All conversations', Colors.teal[300]!, Icons.message),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Thêm Positioned cho bottomNavigationBar (đặt cuối cùng trong Stack để nằm trên cùng)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color.fromARGB(255, 78, 26, 126), Color.fromARGB(255, 192, 154, 223)], // Xanh dương đậm sang xanh nhạt
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.transparent, // Đảm bảo nền trong suốt để gradient hiển thị
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
                          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assignments'),
                          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                        ],
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.white70,
                        currentIndex: _selectedIndex,
                        onTap: _onItemTapped,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      Widget _buildGridTile(String title, String subtitle, Color color, IconData icon) {
        return InkWell(
          onTap: () {
            // Thêm logic khi nhấn vào ô
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening $title')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }