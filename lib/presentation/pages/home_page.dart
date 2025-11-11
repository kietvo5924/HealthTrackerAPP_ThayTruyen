import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';
import 'package:health_tracker_app/presentation/pages/profile_page.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:intl/intl.dart';

// Import trang Thống kê
import 'package:health_tracker_app/presentation/pages/statistics_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HealthDataBloc>(),
      // Không gọi Fetch ở đây
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ'),
          actions: [
            // Nút đi đến trang Biểu đồ
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsPage(),
                  ),
                );
              },
            ),

            // Nút đi đến trang Profile
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            // Nút Đăng xuất
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Gọi event AuthLoggedOut
                context.read<AuthBloc>().add(AuthLoggedOut());
              },
            ),
          ],
        ),

        // Dùng BlocConsumer và gọi Fetch ở đây
        body: BlocConsumer<HealthDataBloc, HealthDataState>(
          listener: (context, state) {
            // Hiển thị SnackBar khi có lỗi
            if (state.status == HealthDataStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
                );
            }
          },
          builder: (context, state) {
            // Nếu là Initial, thì gọi Fetch
            // (Chỉ gọi 1 lần khi BLoC vừa được tạo)
            if (state.status == HealthDataStatus.initial) {
              context.read<HealthDataBloc>().add(
                HealthDataFetched(DateTime.now()),
              );
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == HealthDataStatus.loading) {
              // Đang tải
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == HealthDataStatus.failure &&
                state.healthData.id == null) {
              return Center(child: Text('Lỗi: ${state.errorMessage}'));
            }

            // Hiển thị Dashboard
            return HealthDataDashboard(healthData: state.healthData);
          },
        ),
      ),
    );
  }
}

// Widget mới để hiển thị Bảng điều khiển
class HealthDataDashboard extends StatelessWidget {
  final HealthData healthData;
  const HealthDataDashboard({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    // Sửa lỗi: Bọc bằng SingleChildScrollView để cho phép cuộn
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hôm nay (${DateFormat.yMd().format(healthData.date)})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Hiển thị các chỉ số
            HealthDataTile(
              icon: Icons.run_circle,
              label: 'Bước đi',
              value: healthData.steps?.toString() ?? '0',
              // (Bạn có thể thêm onTap cho 'Bước đi' ở đây)
            ),
            HealthDataTile(
              icon: Icons.local_drink,
              label: 'Nước uống',
              value: '${healthData.waterIntake?.toString() ?? '0'} lít',
              onTap: () {
                _showLogDialog(
                  context,
                  title: 'Nhập lượng nước đã uống',
                  label: 'Số lít (ví dụ: 2.5)',
                  initialValue: healthData.waterIntake?.toString(),
                  onSave: (value) {
                    final double? water = double.tryParse(value);
                    if (water != null) {
                      // 1. Cập nhật state UI
                      context.read<HealthDataBloc>().add(
                        HealthDataWaterChanged(water),
                      );
                      // 2. Gọi API
                      context.read<HealthDataBloc>().add(HealthDataLogged());
                    }
                  },
                );
              },
            ),
            HealthDataTile(
              icon: Icons.monitor_weight,
              label: 'Cân nặng',
              value: '${healthData.weight?.toString() ?? 'N/A'} kg',
              onTap: () {
                _showLogDialog(
                  context,
                  title: 'Nhập cân nặng',
                  label: 'Số kg (ví dụ: 65.5)',
                  initialValue: healthData.weight?.toString(),
                  onSave: (value) {
                    final double? weight = double.tryParse(value);
                    if (weight != null) {
                      context.read<HealthDataBloc>().add(
                        HealthDataWeightChanged(weight),
                      );
                      context.read<HealthDataBloc>().add(HealthDataLogged());
                    }
                  },
                );
              },
            ),
            HealthDataTile(
              icon: Icons.hotel,
              label: 'Giấc ngủ',
              value: '${healthData.sleepHours?.toString() ?? 'N/A'} giờ',
              // (Bạn có thể thêm onTap cho 'Giấc ngủ' ở đây)
            ),
            HealthDataTile(
              icon: Icons.local_fire_department,
              label: 'Calo đốt cháy',
              value: healthData.caloriesBurnt?.toString() ?? '0',
              // (Bạn có thể thêm onTap cho 'Calo' ở đây)
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị Dialog chung
  void _showLogDialog(
    BuildContext context, {
    required String title,
    required String label,
    String? initialValue,
    required Function(String) onSave,
  }) {
    final textController = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextFormField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(textController.text);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}

// Widget con cho từng ô chỉ số
class HealthDataTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap; // Thêm

  const HealthDataTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap, // Thêm
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        // Bọc trong InkWell
        onTap: onTap, // Thêm
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onTap != null) // Thêm
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
