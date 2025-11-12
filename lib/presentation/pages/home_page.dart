import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';
import 'package:health_tracker_app/presentation/pages/profile_page.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:intl/intl.dart';

import 'package:health_tracker_app/presentation/pages/statistics_page.dart';
import 'package:health_tracker_app/presentation/widgets/circular_health_tile.dart';
import 'package:health_tracker_app/presentation/bloc/nutrition/nutrition_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';

// Hàm này sẽ trả về "Hôm nay", "Hôm qua", hoặc "dd/MM/yyyy"
String _buildTitle(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final selectedDay = DateTime(date.year, date.month, date.day);

  if (selectedDay == today) {
    return 'Hôm nay';
  } else if (selectedDay == yesterday) {
    return 'Hôm qua';
  } else {
    return DateFormat.yMMMd('vi_VN').format(date);
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthDataBloc, HealthDataState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Tiêu đề động (dynamic)
            title: Text(
              _buildTitle(state.healthData.date),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            actions: [
              // --- THÊM MỚI: NÚT CHỌN NGÀY ---
              IconButton(
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.black,
                ),
                onPressed: () async {
                  // 1. Hiển thị DatePicker
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: state.healthData.date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(), // Không cho chọn ngày tương lai
                  );

                  // 2. Nếu người dùng chọn ngày mới
                  if (pickedDate != null &&
                      pickedDate != state.healthData.date) {
                    // 3. Gọi CẢ 3 BLoC để tải dữ liệu cho ngày mới
                    context.read<HealthDataBloc>().add(
                      HealthDataFetched(pickedDate),
                    );
                    context.read<NutritionBloc>().add(
                      NutritionGetMeals(pickedDate),
                    );
                    context.read<WorkoutBloc>().add(WorkoutsFetched());
                  }
                },
              ),

              // --- KẾT THÚC THÊM MỚI ---
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
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
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

          // --- SỬA ĐỔI: Bỏ BlocConsumer (vì đã có ở trên) ---
          body: BlocConsumer<HealthDataBloc, HealthDataState>(
            // (Chúng ta giữ BlocConsumer ở đây để xử lý SnackBar)
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

              // Hiển thị Dashboard
              return HealthDataDashboard(healthData: state.healthData);
            },
          ),
        );
      },
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

    // --- SỬA ĐỔI: Kiểm tra xem có phải hôm nay không ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      healthData.date.year,
      healthData.date.month,
      healthData.date.day,
    );
    final bool isToday = (selectedDay == today);
    // --- KẾT THÚC SỬA ĐỔI ---

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const _CalorieSummaryCard(),
              const SizedBox(height: 20),

              // 1. Bước đi
              CircularHealthTile(
                label: 'Bước đi',
                icon: Icons.run_circle_outlined,
                value: healthData.steps?.toString() ?? '0',
                unit: '/ $stepGoal',
                progress: stepProgress > 1.0 ? 1.0 : stepProgress,
                progressColor: Colors.orange,
                onTap: () {
                  // Chỉ cho phép sửa/xem nếu là hôm nay (vì cảm biến đang chạy)
                  if (isToday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Số bước đi được cập nhật tự động.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chỉ có thể xem, không thể sửa bước đi của ngày cũ.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              // 2. Nước uống
              CircularHealthTile(
                label: 'Nước uống',
                icon: Icons.local_drink_outlined,
                value: healthData.waterIntake?.toString() ?? '0',
                unit: 'L',
                progress: waterProgress > 1.0 ? 1.0 : waterProgress,
                progressColor: Colors.blue,
                onTap: () {
                  // --- SỬA ĐỔI: Chỉ cho phép sửa nếu là hôm nay ---
                  if (!isToday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chỉ có thể nhập dữ liệu cho ngày hôm nay.',
                        ),
                      ),
                    );
                    return;
                  }
                  // --- KẾT THÚC SỬA ĐỔI ---

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
              const SizedBox(height: 12),

              // 3. Giấc ngủ
              CircularHealthTile(
                label: 'Giấc ngủ',
                icon: Icons.hotel_outlined,
                value: healthData.sleepHours?.toString() ?? '0',
                unit: 'giờ',
                progress: sleepProgress > 1.0 ? 1.0 : sleepProgress,
                progressColor: Colors.purple,
                onTap: () {
                  if (!isToday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chỉ có thể nhập dữ liệu cho ngày hôm nay.',
                        ),
                      ),
                    );
                    return;
                  }
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
              const SizedBox(height: 12),

              // 4. Calo
              CircularHealthTile(
                label: 'Calo tiêu thụ',
                icon: Icons.local_fire_department_outlined,
                value: healthData.caloriesBurnt?.toString() ?? '0',
                unit: 'kcal',
                progress: caloriesProgress > 1.0 ? 1.0 : caloriesProgress,
                progressColor: Colors.red,
                onTap: () {
                  if (!isToday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chỉ có thể nhập dữ liệu cho ngày hôm nay.',
                        ),
                      ),
                    );
                    return;
                  }
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
              if (!isToday) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chỉ có thể nhập dữ liệu cho ngày hôm nay.'),
                  ),
                );
                return;
              }
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

// --- DÁN CÁC CLASS NÀY VÀO CUỐI FILE home_page.dart ---

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard();

  @override
  Widget build(BuildContext context) {
    // Lấy ngày hiện tại từ HealthDataBloc
    final selectedDate = context.select(
      (HealthDataBloc bloc) => bloc.state.healthData.date,
    );

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng kết Calo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Calo Nạp vào (từ NutritionBloc)
                BlocBuilder<NutritionBloc, NutritionState>(
                  builder: (context, state) {
                    // Chỉ tính calo cho ngày đang chọn
                    if (state.status == NutritionStatus.loading) {
                      return const _StatTile(
                        label: 'Nạp vào',
                        value: '...',
                        unit: 'kcal',
                      );
                    }
                    // Tính tổng calo từ các bữa ăn
                    final caloriesIn = state.meals.fold<double>(
                      0.0,
                      (sum, meal) => sum + meal.totalMealCalories,
                    );
                    return _StatTile(
                      label: 'Nạp vào',
                      value: caloriesIn.toInt().toString(),
                      unit: 'kcal',
                    );
                  },
                ),

                const Text(
                  '-',
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),

                // 2. Calo Tiêu thụ (từ HealthDataBloc)
                BlocBuilder<HealthDataBloc, HealthDataState>(
                  builder: (context, state) {
                    final caloriesOut = state.healthData.caloriesBurnt ?? 0;
                    return _StatTile(
                      label: 'Tiêu thụ',
                      value: caloriesOut.toInt().toString(),
                      unit: 'kcal',
                    );
                  },
                ),

                const Text(
                  '=',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                // 3. Kết quả (Thâm hụt/Dư thừa)
                MultiBlocListener(
                  listeners: [
                    // Dùng MultiBlocListener để lấy state từ nhiều BLoC
                    // và tính toán kết quả cuối cùng
                    BlocListener<NutritionBloc, NutritionState>(
                      listener: (context, state) {},
                    ),
                    BlocListener<HealthDataBloc, HealthDataState>(
                      listener: (context, state) {},
                    ),
                  ],
                  child: Builder(
                    builder: (context) {
                      // Lấy state một cách an toàn
                      final nutritionState = context
                          .watch<NutritionBloc>()
                          .state;
                      final healthState = context.watch<HealthDataBloc>().state;

                      final caloriesIn = nutritionState.meals.fold<double>(
                        0.0,
                        (sum, meal) => sum + meal.totalMealCalories,
                      );
                      final caloriesOut =
                          healthState.healthData.caloriesBurnt ?? 0;
                      final remaining = caloriesIn - caloriesOut;

                      final isDeficit = remaining < 0; // Thâm hụt

                      return _StatTile(
                        label: isDeficit ? 'Thâm hụt' : 'Dư thừa',
                        value: remaining.toInt().abs().toString(),
                        unit: 'kcal',
                        valueColor: isDeficit ? Colors.green : Colors.red,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Thông tin thêm: Calo từ Vận động (từ WorkoutBloc)
            BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                // Lọc và tính tổng calo từ các bài tập trong ngày đã chọn
                final activeCalories = state.workouts
                    .where(
                      (w) => DateUtils.isSameDay(
                        w.startedAt.toLocal(),
                        selectedDate,
                      ),
                    )
                    .fold<double>(
                      0.0,
                      (sum, w) => sum + (w.caloriesBurned ?? 0),
                    );

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.deepOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vận động đốt: ${activeCalories.toInt()} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget con để hiển thị chỉ số (tái sử dụng từ trang detail)
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black, // Màu mặc định
          ),
        ),
        Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
