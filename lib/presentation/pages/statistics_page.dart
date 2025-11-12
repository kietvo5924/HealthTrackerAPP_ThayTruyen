import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/data/models/health_data_model.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/presentation/bloc/statistics/statistics_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Import để dùng 'pi' cho việc xoay

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<StatisticsBloc>()..add(StatisticsFetched(endDate: DateTime.now())),
      child: Scaffold(
        appBar: AppBar(title: const Text('Thống kê 7 ngày')),
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
            // Dùng SingleChildScrollView (cuộn dọc) cho toàn bộ trang
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Biểu đồ Nước uống
                  Text(
                    'Biểu đồ Nước uống (lít)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  // Bọc biểu đồ bằng cuộn ngang
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 500,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: WaterChart(dataList: state.healthDataList),
                      ),
                    ),
                  ),

                  // 2. Biểu đồ Bước đi
                  const SizedBox(height: 32),
                  Text(
                    'Biểu đồ Bước đi (7 ngày)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  // Bọc biểu đồ bằng cuộn ngang
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 500,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: StepsLineChart(dataList: state.healthDataList),
                      ),
                    ),
                  ),

                  // 3. Biểu đồ Giấc ngủ (MỚI)
                  const SizedBox(height: 32),
                  Text(
                    'Biểu đồ Giấc ngủ (giờ)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  // Bọc biểu đồ bằng cuộn ngang
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 500,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: SleepChart(dataList: state.healthDataList),
                      ),
                    ),
                  ),

                  // 4. Biểu đồ Calo (MỚI)
                  const SizedBox(height: 32),
                  Text(
                    'Biểu đồ Calo tiêu thụ (kcal)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  // Bọc biểu đồ bằng cuộn ngang
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 500,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 16),
                        child: CaloriesChart(dataList: state.healthDataList),
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
// BIỂU ĐỒ NƯỚC UỐNG (Bar Chart)
// -----------------------------------------------------------------
class WaterChart extends StatelessWidget {
  final List<HealthData> dataList;
  const WaterChart({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();
    double maxY = 5; // Tối thiểu 5 lít

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () => HealthDataModel(date: date),
      );

      // Cập nhật maxY nếu cần
      if ((data.waterIntake ?? 0) > maxY) {
        maxY = (data.waterIntake! * 1.2);
      }

      barGroups.add(
        BarChartGroupData(
          x: 6 - i, // Vị trí 0 -> 6
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
          bottomTitles: _bottomTitles(today),
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
// BIỂU ĐỒ BƯỚC ĐI (Line Chart)
// -----------------------------------------------------------------
class StepsLineChart extends StatelessWidget {
  final List<HealthData> dataList;
  const StepsLineChart({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    final today = DateTime.now();
    double maxY = 10000; // Tối thiểu 10k bước

    for (int i = 6; i >= 0; i--) {
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

      spots.add(FlSpot((6 - i).toDouble(), steps)); // X: 0-6, Y: steps
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today), // Dùng chung hàm
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
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// BIỂU ĐỒ GIẤC NGỦ (Bar Chart) - MỚI
// -----------------------------------------------------------------
class SleepChart extends StatelessWidget {
  final List<HealthData> dataList;
  const SleepChart({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();
    double maxY = 8; // Tối thiểu 8 giờ

    for (int i = 6; i >= 0; i--) {
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
          x: 6 - i, // Vị trí 0 -> 6
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
          bottomTitles: _bottomTitles(today),
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
// BIỂU ĐỒ CALO (Line Chart) - MỚI
// -----------------------------------------------------------------
class CaloriesChart extends StatelessWidget {
  final List<HealthData> dataList;
  const CaloriesChart({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    final today = DateTime.now();
    double maxY = 2500; // Tối thiểu 2500 kcal

    for (int i = 6; i >= 0; i--) {
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

      spots.add(FlSpot((6 - i).toDouble(), calories)); // X: 0-6, Y: calories
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: _bottomTitles(today), // Dùng chung hàm
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
AxisTitles _bottomTitles(DateTime today) {
  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        final daysAgo = 6 - value.toInt();
        final date = today.subtract(Duration(days: daysAgo));

        // ----- SỬA LỖI Ở ĐÂY -----
        return SideTitleWidget(
          meta: meta,
          space: 4.0,
          angle: -pi / 4, // Xoay 45 độ
          child: Text(
            DateFormat('dd/MM').format(date),
            style: const TextStyle(fontSize: 10),
          ),
        );
        // ----- KẾT THÚC SỬA LỖI -----
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
        if (value == 0 || value > maxY)
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
