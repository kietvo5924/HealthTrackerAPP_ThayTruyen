import 'package:flutter/material.dart';
import 'package:health_tracker_app/presentation/pages/home_page.dart';
import 'package:health_tracker_app/presentation/pages/profile_page.dart';
import 'package:health_tracker_app/presentation/pages/statistics_page.dart';
import 'package:health_tracker_app/presentation/pages/workout_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  // Danh sách các trang con
  final List<Widget> _pages = const [
    HomePage(),
    StatisticsPage(),
    WorkoutPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng IndexedStack để giữ trạng thái (state) của các trang
      // khi chuyển tab (rất quan trọng cho BLoC và cảm biến bước đi)
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Thanh điều hướng dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // --- Quan trọng: Thêm các dòng sau ---
        type: BottomNavigationBarType.fixed, // Để hiển thị 4+ mục
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,

        // --- Hết phần quan trọng ---
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Bài tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
