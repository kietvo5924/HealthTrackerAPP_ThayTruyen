import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart' as di;
import 'package:health_tracker_app/core/services/notification_service.dart';
import 'package:health_tracker_app/firebase_options.dart';
import 'package:health_tracker_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:health_tracker_app/presentation/pages/home_page.dart';
import 'package:health_tracker_app/presentation/pages/login_page.dart';
import 'package:health_tracker_app/presentation/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Đảm bảo Flutter đã khởi tạo xong
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo Dependency Injection
  await di.init();

  // Khởi tạo Service lắng nghe thông báo
  di.sl<NotificationService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp AuthBloc cho toàn bộ ứng dụng
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'Health Tracker',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // Điều hướng dựa trên trạng thái AuthBloc
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomePage();
            }
            if (state is AuthUnauthenticated) {
              return const LoginPage();
            }
            // (AuthInitial hoặc AuthLoading)
            return const SplashPage();
          },
        ),
      ),
    );
  }
}
