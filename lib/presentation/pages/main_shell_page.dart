import 'package:flutter/material.dart';
import 'package:health_tracker_app/presentation/bloc/notification/notification_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/notification/notification_event.dart';
import 'package:health_tracker_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:health_tracker_app/presentation/pages/home_page.dart';
import 'package:health_tracker_app/presentation/pages/nutrition_page.dart';
import 'package:health_tracker_app/presentation/pages/profile_page.dart';
import 'package:health_tracker_app/presentation/pages/statistics_page.dart';
import 'package:health_tracker_app/presentation/pages/workout_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/nutrition/nutrition_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';

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
    NutritionPage(),
    WorkoutPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) =>
              sl<ProfileBloc>()..add(ProfileFetched()), // <-- Gọi event ở đây
        ),
        // Cung cấp HealthDataBloc cho toàn bộ các tab
        BlocProvider(
          create: (context) =>
              sl<HealthDataBloc>()..add(HealthDataFetched(DateTime.now())),
        ),
        // Cung cấp NutritionBloc
        BlocProvider(
          create: (context) =>
              sl<NutritionBloc>()..add(NutritionGetMeals(DateTime.now())),
        ),
        // Cung cấp WorkoutBloc
        BlocProvider(
          create: (context) => sl<WorkoutBloc>()..add(WorkoutsFetched()),
        ),
        BlocProvider(
          create: (_) =>
              sl<NotificationBloc>()..add(NotificationCountChecked()),
        ),
      ],
      child: Scaffold(
        // Sử dụng IndexedStack để giữ trạng thái (state) của các trang
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
              icon: Icon(Icons.restaurant_menu_outlined), // Đổi Icon
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Dinh dưỡng', // Đổi Label
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
      ),
    );
  }
}
