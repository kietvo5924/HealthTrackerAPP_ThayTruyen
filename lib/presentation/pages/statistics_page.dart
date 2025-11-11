import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/presentation/bloc/statistics/statistics_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Biểu đồ Nước uống (lít)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  // Biểu đồ
                  WaterChart(dataList: state.healthDataList),

                  // (Bạn có thể thêm các biểu đồ khác ở đây)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget Biểu đồ (dùng BarChart)
class WaterChart extends StatelessWidget {
  final List<HealthData> dataList;
  const WaterChart({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    // Tạo các điểm dữ liệu cho biểu đồ
    final List<BarChartGroupData> barGroups = [];

    final today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));

      final data = dataList.firstWhere(
        (item) =>
            DateFormat('yyyy-MM-dd').format(item.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () => HealthData(date: date),
      );

      barGroups.add(
        BarChartGroupData(
          x: 6 - i, // Vị trí 0 -> 6
          barRods: [
            BarChartRodData(
              toY: data.waterIntake ?? 0,
              color: Theme.of(context).primaryColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5, // 5 lít là tối đa
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  // value là 0 -> 6
                  final daysAgo = 6 - value.toInt();
                  final date = today.subtract(Duration(days: daysAgo));

                  // ----- SỬA LỖI 1: Xóa 'axisSide' -----
                  return SideTitleWidget(
                    meta: meta,
                    space: 4.0,
                    child: Text(DateFormat('dd/MM').format(date)),
                  );
                },
                reservedSize: 38,
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28, // Kích thước dành cho nhãn
                getTitlesWidget: (double value, TitleMeta meta) {
                  // ----- SỬA LỖI 2: Trả về 'SideTitleWidget' -----
                  if (value % 1 == 0 && value <= 5) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4.0,
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.left,
                      ),
                    );
                  }
                  // Trả về một SideTitleWidget rỗng
                  return SideTitleWidget(meta: meta, child: const Text(''));
                },
              ),
            ),

            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
