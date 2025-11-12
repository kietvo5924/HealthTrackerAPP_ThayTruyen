import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:health_tracker_app/presentation/pages/workout_detail_page.dart';
import 'package:intl/intl.dart';

import 'package:health_tracker_app/presentation/pages/tracking_page.dart';

// --- THÊM IMPORT MỚI ---
import 'package:health_tracker_app/core/utils/string_extensions.dart';
// --- KẾT THÚC THÊM MỚI ---

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<WorkoutBloc>()..add(WorkoutsFetched()), // Tải khi mở
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài tập của tôi'),
          actions: [
            // Nút Refresh
            BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                // Chỉ hiển thị loading nếu không phải là đang submit
                if (state.status == WorkoutStatus.loading &&
                    !state.isSubmitting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<WorkoutBloc>().add(WorkoutsFetched());
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, state) {
            // Trạng thái Lỗi
            if (state.status == WorkoutStatus.failure) {
              return Center(child: Text('Lỗi: ${state.errorMessage}'));
            }

            // Trạng thái Tải (ngoại trừ lúc đang submit)
            if ((state.status == WorkoutStatus.loading ||
                    state.status == WorkoutStatus.initial) &&
                !state.isSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Trạng thái Rỗng (Thành công nhưng không có dữ liệu)
            if (state.status == WorkoutStatus.success &&
                state.workouts.isEmpty) {
              return const Center(
                child: Text(
                  'Bạn chưa ghi bài tập nào.\nNhấn dấu + để bắt đầu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // Trạng thái Thành công (có dữ liệu)
            return ListView.builder(
              itemCount: state.workouts.length,
              itemBuilder: (context, index) {
                final workout = state.workouts[index];
                return _WorkoutListTile(workout: workout);
              },
            );
          },
        ),
        floatingActionButton: BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, state) {
            return FloatingActionButton(
              // --- SỬA LỖI 2 (Hero) ---
              heroTag: 'add_workout_button', // Đặt 1 tag duy nhất
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<WorkoutBloc>(context),
                      child: const TrackingPage(),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

// Widget private cho từng item trong danh sách
class _WorkoutListTile extends StatelessWidget {
  final Workout workout;

  const _WorkoutListTile({required this.workout});

  // Helper để lấy Icon
  IconData _getIconForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.RUNNING:
        return Icons.directions_run;
      case WorkoutType.WALKING:
        return Icons.directions_walk;
      case WorkoutType.CYCLING:
        return Icons.directions_bike;
      case WorkoutType.GYM:
        return Icons.fitness_center;
      case WorkoutType.SWIMMING:
        return Icons.pool;
      default:
        return Icons.sports; // Đã sửa lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          _getIconForType(workout.workoutType),
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          // Chuyển "RUNNING" thành "Running"
          workout.workoutType.toString().split('.').last.capitalize(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          // Hiển thị ngày và giờ
          DateFormat.yMd().add_Hm().format(workout.startedAt.toLocal()),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${workout.durationInMinutes} phút',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            // Hiển thị quãng đường (nếu có)
            if (workout.distanceInKm != null && workout.distanceInKm! > 0)
              Text(
                '${workout.distanceInKm!.toStringAsFixed(2)} km',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              )
            // Hiển thị calo (nếu có)
            else if (workout.caloriesBurned != null)
              Text(
                '${workout.caloriesBurned?.toInt()} kcal',
                style: const TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutDetailPage(workout: workout),
            ),
          );
        },
      ),
    );
  }
}
