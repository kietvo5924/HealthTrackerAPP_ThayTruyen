import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/data/models/health_data_model.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/presentation/bloc/statistics/statistics_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Import để dùng 'pi' cho việc xoay

// === THÊM IMPORT CHO CÁC MODEL (ĐỂ SỬA LỖI) ===
import 'package:health_tracker_app/data/models/nutrition_summary_model.dart';
import 'package:health_tracker_app/data/models/workout_summary_model.dart';
// === KẾT THÚC ===

import 'package:health_tracker_app/domain/entities/nutrition_summary.dart';
import 'package:health_tracker_app/domain/entities/workout_summary.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<StatisticsBloc>()..add(StatisticsFetched(endDate: DateTime.now())),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<StatisticsBloc, StatisticsState>(
            builder: (context, state) {
              return Text('Thống kê ${state.selectedDays} ngày');
            },
          ),
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state.status == StatisticsStatus.loading ||
                state.status == StatisticsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == StatisticsStatus.failure) {
              return Center(child: Text('Lỗi: ${state.errorMessage}'));
            }

            // Khi thành công
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ToggleButtons(
                      isSelected: [
                        state.selectedDays == 7, // Nút 7 ngày
                        state.selectedDays == 30, // Nút 30 ngày
                      ],
                      onPressed: (index) {
                        final days = (index == 0) ? 7 : 30;
                        if (days != state.selectedDays) {
                          context.read<StatisticsBloc>().add(
                            StatisticsDaysChanged(days),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('7 ngày'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('30 ngày'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === BIỂU ĐỒ 1: DINH DƯỠNG (MỚI) ===
                  Text(
                    'Dinh dưỡng nạp vào (${state.selectedDays} ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: state.selectedDays * 60.0,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: _NutritionSummaryChart(
                          dataList: state.nutritionSummaryList,
                          days: state.selectedDays,
                        ),
                      ),
                    ),
                  ),

                  // === BIỂU ĐỒ 2: LUYỆN TẬP (MỚI) ===
                  const SizedBox(height: 32),
                  Text(
                    'Thời gian luyện tập (${state.selectedDays} ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: state.selectedDays * 60.0,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: _WorkoutSummaryChart(
                          dataList: state.workoutSummaryList,
                          days: state.selectedDays,
                        ),
                      ),
                    ),
                  ),

                  // 3. Biểu đồ Nước uống
                  const SizedBox(height: 32),
                  Text(
                    'Nước uống (${state.selectedDays} ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: state.selectedDays * 60.0,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: _WaterChart(
                          dataList: state.healthDataList,
                          days: state.selectedDays,
                        ),
                      ),
                    ),
                  ),

                  // 4. Biểu đồ Bước đi
                  const SizedBox(height: 32),
                  Text(
                    'Bước đi (${state.selectedDays} ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: state.selectedDays * 60.0,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: _StepsLineChart(
                          dataList: state.healthDataList,
                          days: state.selectedDays,
                        ),
                      ),
                    ),
                  ),

                  // 5. Biểu đồ Giấc ngủ
                  const SizedBox(height: 32),
                  Text(
                    'Giấc ngủ (${state.selectedDays} ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: state.selectedDays * 60.0,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: _SleepChart(
                          dataList: state.healthDataList,
                          days: state.selectedDays,
                        ),
                      ),
                    ),
                  ),

                  // 6. Biểu đồ Calo (từ HealthData)
                  const SizedBox(height: 32),
                  Text(
                    'Calo tiêu thụ (${state.selectedDays} ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: state.selectedDays * 60.0,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: _CaloriesChart(
                          dataList: state.healthDataList,
                          days: state.selectedDays,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ DINH DƯỠNG (Stacked Bar Chart - MỚI)
// -----------------------------------------------------------------
class _NutritionSummaryChart extends StatelessWidget {
  final List<NutritionSummary> dataList;
  final int days;

  const _NutritionSummaryChart({required this.dataList, required this.days});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();
    double maxY = 2500; // Tối thiểu 2500 kcal

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),

        // === SỬA LỖI TẠI ĐÂY: Trả về NutritionSummaryModel ===
        orElse: () => NutritionSummaryModel(
          date: date,
          totalProtein: 0,
          totalCarbs: 0,
          totalFat: 0,
          totalCalories: 0,
        ),
      );

      // Tính calo từ P-C-F (1g P = 4 kcal, 1g C = 4 kcal, 1g F = 9 kcal)
      final double proteinCals = data.totalProtein * 4;
      final double carbsCals = data.totalCarbs * 4;
      final double fatCals = data.totalFat * 9;
      final double totalCals = proteinCals + carbsCals + fatCals;

      if (totalCals > maxY) {
        maxY = totalCals * 1.2;
      }

      barGroups.add(
        BarChartGroupData(
          x: (days - 1) - i,
          barRods: [
            BarChartRodData(
              toY: totalCals,
              width: 22,
              borderRadius: BorderRadius.circular(4),
              // Đây là phần xếp chồng
              rodStackItems: [
                // Protein (Xanh)
                BarChartRodStackItem(0, proteinCals, Colors.blue),
                // Carb (Xanh lá)
                BarChartRodStackItem(
                  proteinCals,
                  proteinCals + carbsCals,
                  Colors.green,
                ),
                // Fat (Đỏ)
                BarChartRodStackItem(
                  proteinCals + carbsCals,
                  totalCals,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.ceilToDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today, days),
          leftTitles: _leftTitles(1000, maxY.ceilToDouble()), // 1k, 2k, ...
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barGroups: barGroups,
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ LUYỆN TẬP (Bar Chart - MỚI)
// -----------------------------------------------------------------
class _WorkoutSummaryChart extends StatelessWidget {
  final List<WorkoutSummary> dataList;
  final int days;

  const _WorkoutSummaryChart({required this.dataList, required this.days});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();
    double maxY = 60; // Tối thiểu 60 phút

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),

        // === SỬA LỖI TẠI ĐÂY: Trả về WorkoutSummaryModel ===
        orElse: () => WorkoutSummaryModel(
          date: date,
          totalDurationInMinutes: 0,
          totalCaloriesBurned: 0,
          totalDistanceInKm: 0,
        ),
      );

      final double duration = data.totalDurationInMinutes.toDouble();
      if (duration > maxY) {
        maxY = duration * 1.2;
      }

      barGroups.add(
        BarChartGroupData(
          x: (days - 1) - i,
          barRods: [
            BarChartRodData(
              toY: duration,
              color: Colors.deepOrange,
              width: 22,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.ceilToDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today, days),
          leftTitles: _leftTitles(30, maxY.ceilToDouble()), // 30, 60, 90...
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barGroups: barGroups,
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ NƯỚC UỐNG (Đổi tên thành _WaterChart)
// -----------------------------------------------------------------
class _WaterChart extends StatelessWidget {
  final List<HealthData> dataList;
  final int days;

  const _WaterChart({required this.dataList, required this.days});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();
    double maxY = 5; // Tối thiểu 5 lít

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        // Chỗ này vẫn dùng HealthDataModel là đúng
        orElse: () => HealthDataModel(date: date),
      );

      // Cập nhật maxY nếu cần
      if ((data.waterIntake ?? 0) > maxY) {
        maxY = (data.waterIntake! * 1.2);
      }

      barGroups.add(
        BarChartGroupData(
          x: (days - 1) - i,
          barRods: [
            BarChartRodData(
              toY: data.waterIntake ?? 0,
              color: Colors.blue,
              width: 22,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.ceilToDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today, days),
          leftTitles: _leftTitles(
            1,
            maxY.ceilToDouble(),
          ), // Hiển thị số 1, 2, 3, 4...
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barGroups: barGroups,
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ BƯỚC ĐI (Đổi tên thành _StepsLineChart)
// -----------------------------------------------------------------
class _StepsLineChart extends StatelessWidget {
  final List<HealthData> dataList;
  final int days;

  const _StepsLineChart({required this.dataList, required this.days});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    final today = DateTime.now();
    double maxY = 10000; // Tối thiểu 10k bước

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () => HealthDataModel(date: date),
      );

      final double steps = data.steps?.toDouble() ?? 0;
      if (steps > maxY) {
        maxY = steps * 1.2; // Tăng max Y nếu vượt mục tiêu
      }

      spots.add(FlSpot(((days - 1) - i).toDouble(), steps));
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today, days),
          leftTitles: _leftTitles(
            5000,
            maxY.ceilToDouble(),
          ), // Hiển thị 5k, 10k
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              // ignore: deprecated_member_use
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ GIẤC NGỦ (Đổi tên thành _SleepChart)
// -----------------------------------------------------------------
class _SleepChart extends StatelessWidget {
  final List<HealthData> dataList;
  final int days;

  const _SleepChart({required this.dataList, required this.days});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();
    double maxY = 8; // Tối thiểu 8 giờ

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () => HealthDataModel(date: date),
      );

      if ((data.sleepHours ?? 0) > maxY) {
        maxY = (data.sleepHours! * 1.2);
      }

      barGroups.add(
        BarChartGroupData(
          x: (days - 1) - i,
          barRods: [
            BarChartRodData(
              toY: data.sleepHours ?? 0,
              color: Colors.purple,
              width: 22,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.ceilToDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today, days),
          leftTitles: _leftTitles(
            2,
            maxY.ceilToDouble(),
          ), // Hiển thị 2, 4, 6...
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barGroups: barGroups,
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ CALO (Đổi tên thành _CaloriesChart)
// -----------------------------------------------------------------
class _CaloriesChart extends StatelessWidget {
  final List<HealthData> dataList;
  final int days;

  const _CaloriesChart({required this.dataList, required this.days});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    final today = DateTime.now();
    double maxY = 2500; // Tối thiểu 2500 kcal

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () => HealthDataModel(date: date),
      );

      final double calories = data.caloriesBurnt?.toDouble() ?? 0;
      if (calories > maxY) {
        maxY = calories * 1.2;
      }

      spots.add(FlSpot(((days - 1) - i).toDouble(), calories));
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today, days),
          leftTitles: _leftTitles(
            1000,
            maxY.ceilToDouble(),
          ), // Hiển thị 1k, 2k...
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              // ignore: deprecated_member_use
              color: Colors.red.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// HÀM HELPER DÙNG CHUNG CHO TRỤC X (NGÀY THÁNG)
// -----------------------------------------------------------------
AxisTitles _bottomTitles(DateTime today, int days) {
  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        final daysAgo = (days - 1) - value.toInt();
        final date = today.subtract(Duration(days: daysAgo));

        // Chỉ hiển thị label cho một số ngày nếu là 30 ngày
        if (days == 30 && value % 5 != 0) {
          // Chỉ hiển thị mỗi 5 ngày
          return SideTitleWidget(meta: meta, child: const Text(''));
        }

        return SideTitleWidget(
          meta: meta,
          space: 4.0,
          angle: -pi / 4, // Xoay 45 độ
          child: Text(
            DateFormat('dd/MM').format(date),
            style: const TextStyle(fontSize: 10),
          ),
        );
      },
      reservedSize: 38,
    ),
  );
}

// -----------------------------------------------------------------
// HÀM HELPER DÙNG CHUNG CHO TRỤC Y (GIÁ TRỊ)
// -----------------------------------------------------------------
AxisTitles _leftTitles(double interval, double maxY) {
  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 40,
      getTitlesWidget: (double value, TitleMeta meta) {
        if (value == 0) // Chỉ ẩn số 0
          // ignore: curly_braces_in_flow_control_structures
          return SideTitleWidget(meta: meta, child: const Text(''));

        // Nếu là số lớn (hàng nghìn), hiển thị "k"
        if (interval >= 1000) {
          if (value % interval == 0) {
            return SideTitleWidget(
              meta: meta,
              space: 4.0,
              child: Text(
                '${(value / 1000).toInt()}k',
                style: const TextStyle(fontSize: 10),
              ),
            );
          }
        }
        // Nếu là số nhỏ (giờ, lít)
        else {
          if (value % interval == 0) {
            return SideTitleWidget(
              meta: meta,
              space: 4.0,
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            );
          }
        }
        return SideTitleWidget(meta: meta, child: const Text(''));
      },
    ),
  );
}
