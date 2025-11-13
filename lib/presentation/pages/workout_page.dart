import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:health_tracker_app/presentation/pages/feed_page.dart';
import 'package:health_tracker_app/presentation/pages/workout_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_app/presentation/pages/add_workout_page.dart';
import 'package:health_tracker_app/presentation/pages/tracking_page.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài tập'),
          actions: [
            // Nút Refresh
            BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                // (Code nút Refresh đã có)
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
          // Thêm TabBar
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bài tập của tôi'),
              Tab(text: 'Cộng đồng'),
            ],
          ),
        ),

        // Thay body bằng TabBarView
        body: TabBarView(
          children: [
            // Tab 1: Bài tập của tôi
            _MyWorkoutsView(),

            // Tab 2: Cộng đồng
            FeedPage(), // Sử dụng lại FeedPage ở đây
          ],
        ),

        floatingActionButton: BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, state) {
            return FloatingActionButton(
              heroTag: 'add_workout_button',
              onPressed: () {
                // Gọi hàm hiển thị lựa chọn
                _showAddWorkoutOptions(context);
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showAddWorkoutOptions(BuildContext pageContext) {
    // pageContext là context của trang WorkoutPage, có chứa WorkoutBloc
    showModalBottomSheet(
      context: pageContext,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.gps_fixed),
                title: const Text('Bắt đầu bài tập (Tracking GPS)'),
                onTap: () {
                  Navigator.of(sheetContext).pop(); // Đóng BottomSheet
                  Navigator.of(pageContext).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<WorkoutBloc>(pageContext),
                        child: const TrackingPage(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Ghi lại thủ công'),
                onTap: () {
                  Navigator.of(sheetContext).pop(); // Đóng BottomSheet
                  Navigator.of(pageContext).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<WorkoutBloc>(pageContext),
                        // Mở trang AddWorkoutPage
                        child: const AddWorkoutPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyWorkoutsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
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
        if (state.status == WorkoutStatus.success && state.workouts.isEmpty) {
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
              builder: (_) => BlocProvider.value(
                value: context.read<WorkoutBloc>(),
                child: WorkoutDetailPage(workout: workout),
              ),
            ),
          );
        },
      ),
    );
  }
}
