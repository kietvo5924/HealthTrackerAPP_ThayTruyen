import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/utils/string_extensions.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/presentation/bloc/feed/feed_bloc.dart';
import 'package:intl/intl.dart';

class WorkoutFeedTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const WorkoutFeedTile({
    super.key,
    required this.workout,
    required this.onTap,
  });

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
        return Icons.sports;
    }
  }

  // Helper để tạo tiêu đề
  String _buildTitle() {
    String activity = workout.workoutType
        .toString()
        .split('.')
        .last
        .capitalize();

    if (workout.distanceInKm != null && workout.distanceInKm! > 0) {
      return '$activity - ${workout.distanceInKm!.toStringAsFixed(2)} km';
    } else {
      return '$activity - ${workout.durationInMinutes} phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng trên: Tên người dùng và Ngày
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      // Lấy 2 chữ cái đầu
                      workout.userFullName?.substring(0, 2).toUpperCase() ??
                          '??',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.userFullName ?? 'Một người dùng',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat.yMd().add_Hm().format(
                          workout.startedAt.toLocal(),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Hàng 2: Chi tiết bài tập (Icon và Tên)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getIconForType(workout.workoutType),
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  // Chi tiết
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _buildTitle(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (workout.caloriesBurned != null)
                        Text(
                          'Đã đốt: ${workout.caloriesBurned?.toInt()} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Hàng 3: Bản đồ (nếu có)
              if (workout.routePolyline != null &&
                  workout.routePolyline!.isNotEmpty)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '(Bản đồ thu nhỏ sẽ hiển thị ở đây)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  // (Nâng cao: Có thể dùng widget 'flutter_map'
                  // với Polyline ở đây, nhưng sẽ phức tạp hơn)
                ),
              const Divider(height: 24, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Nút Like
                  IconButton(
                    icon: Icon(
                      workout.likedByCurrentUser
                          ? Icons
                                .favorite // Đã like
                          : Icons.favorite_border, // Chưa like
                      color: workout.likedByCurrentUser
                          ? Colors.redAccent
                          : Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      // Gọi BLoC, workout.id là int
                      context.read<FeedBloc>().add(
                        FeedWorkoutLiked(workout.id),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${workout.likeCount} lượt thích',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // (Bạn có thể thêm nút Bình luận ở đây sau)
                  // const SizedBox(width: 24),
                  // const Icon(Icons.comment_outlined, color: Colors.grey),
                  // const SizedBox(width: 8),
                  // Text('Bình luận'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
