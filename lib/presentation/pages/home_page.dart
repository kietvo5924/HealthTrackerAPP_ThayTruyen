import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';
import 'package:health_tracker_app/presentation/pages/profile_page.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:intl/intl.dart';

import 'package:health_tracker_app/presentation/pages/statistics_page.dart';
import 'package:health_tracker_app/presentation/widgets/circular_health_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HealthDataBloc>(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Tổng quan',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLoggedOut());
              },
            ),
          ],
        ),
        body: BlocConsumer<HealthDataBloc, HealthDataState>(
          listener: (context, state) {
            if (state.status == HealthDataStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
                );
            }
          },
          builder: (context, state) {
            if (state.status == HealthDataStatus.initial) {
              context.read<HealthDataBloc>().add(
                HealthDataFetched(DateTime.now()),
              );
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == HealthDataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == HealthDataStatus.failure &&
                state.healthData.id == null) {
              return Center(child: Text('Lỗi: ${state.errorMessage}'));
            }

            return HealthDataDashboard(healthData: state.healthData);
          },
        ),
      ),
    );
  }
}

class HealthDataDashboard extends StatelessWidget {
  final HealthData healthData;
  const HealthDataDashboard({super.key, required this.healthData});

  // Đặt mục tiêu
  final int stepGoal = 8000;
  final double waterGoal = 2.5;
  final double sleepGoal = 8;
  final int caloriesGoal = 2000;

  @override
  Widget build(BuildContext context) {
    // Tính toán % tiến độ
    final double stepProgress = (healthData.steps ?? 0) / stepGoal;
    final double waterProgress = (healthData.waterIntake ?? 0) / waterGoal;
    final double sleepProgress = (healthData.sleepHours ?? 0) / sleepGoal;
    final double caloriesProgress =
        (healthData.caloriesBurnt ?? 0) / caloriesGoal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hôm nay, ${DateFormat.yMMMd().format(healthData.date)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ----- SỬA LỖI: Thay GridView bằng Column -----
          Column(
            children: [
              // 1. Bước đi
              CircularHealthTile(
                label: 'Bước đi',
                icon: Icons.run_circle_outlined,
                value: healthData.steps?.toString() ?? '0',
                unit: '/ $stepGoal',
                progress: stepProgress > 1.0 ? 1.0 : stepProgress,
                progressColor: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Số bước đi được cập nhật tự động.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12), // Thêm khoảng cách
              // 2. Nước uống
              CircularHealthTile(
                label: 'Nước uống',
                icon: Icons.local_drink_outlined,
                value: healthData.waterIntake?.toString() ?? '0',
                unit: 'L',
                progress: waterProgress > 1.0 ? 1.0 : waterProgress,
                progressColor: Colors.blue,
                onTap: () {
                  _showLogDialog(
                    context,
                    title: 'Nhập lượng nước đã uống',
                    label: 'Số lít (ví dụ: 2.5)',
                    initialValue: healthData.waterIntake?.toString(),
                    onSave: (value) {
                      final double? water = double.tryParse(value);
                      if (water != null) {
                        context.read<HealthDataBloc>().add(
                          HealthDataWaterChanged(water),
                        );
                        context.read<HealthDataBloc>().add(HealthDataLogged());
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12), // Thêm khoảng cách
              // 3. Giấc ngủ
              CircularHealthTile(
                label: 'Giấc ngủ',
                icon: Icons.hotel_outlined,
                value: healthData.sleepHours?.toString() ?? '0',
                unit: 'giờ',
                progress: sleepProgress > 1.0 ? 1.0 : sleepProgress,
                progressColor: Colors.purple,
                onTap: () {
                  _showLogDialog(
                    context,
                    title: 'Nhập số giờ ngủ',
                    label: 'Số giờ (ví dụ: 7.5)',
                    initialValue: healthData.sleepHours?.toString(),
                    onSave: (value) {
                      final double? sleep = double.tryParse(value);
                      if (sleep != null) {
                        context.read<HealthDataBloc>().add(
                          HealthDataSleepChanged(sleep),
                        );
                        context.read<HealthDataBloc>().add(HealthDataLogged());
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12), // Thêm khoảng cách
              // 4. Calo
              CircularHealthTile(
                label: 'Calo tiêu thụ',
                icon: Icons.local_fire_department_outlined,
                value: healthData.caloriesBurnt?.toString() ?? '0',
                unit: 'kcal',
                progress: caloriesProgress > 1.0 ? 1.0 : caloriesProgress,
                progressColor: Colors.red,
                onTap: () {
                  _showLogDialog(
                    context,
                    title: 'Nhập calo tiêu thụ',
                    label: 'Số calo (kcal)',
                    initialValue: healthData.caloriesBurnt?.toString(),
                    onSave: (value) {
                      final double? calories = double.tryParse(value);
                      if (calories != null) {
                        context.read<HealthDataBloc>().add(
                          HealthDataCaloriesChanged(calories),
                        );
                        context.read<HealthDataBloc>().add(HealthDataLogged());
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // ----- KẾT THÚC SỬA LỖI -----
          const SizedBox(height: 20),
          Text(
            'Cân nặng hiện tại',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Dùng lại HealthDataTile cũ cho Cân nặng
          HealthDataTile(
            icon: Icons.monitor_weight_outlined,
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
        ],
      ),
    );
  }

  // Hàm hiển thị Dialog chung (Không thay đổi)
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

// Widget con cho từng ô chỉ số (Tile hình chữ nhật)
class HealthDataTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const HealthDataTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
              if (onTap != null)
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
