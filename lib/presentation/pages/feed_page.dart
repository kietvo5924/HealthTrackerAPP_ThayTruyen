import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/feed/feed_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:health_tracker_app/presentation/pages/workout_detail_page.dart';
import 'package:health_tracker_app/presentation/widgets/workout_feed_tile.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeedBloc>()..add(FeedFetched()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Bảng tin')),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            // Trạng thái Lỗi
            if (state.status == FeedStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${state.errorMessage}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FeedBloc>().add(FeedFetched());
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Trạng thái Tải
            if (state.status == FeedStatus.loading ||
                state.status == FeedStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Trạng thái Rỗng
            if (state.status == FeedStatus.success && state.workouts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có hoạt động nào trong cộng đồng.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FeedBloc>().add(FeedFetched());
                      },
                      child: const Text('Tải lại'),
                    ),
                  ],
                ),
              );
            }

            // Trạng thái Thành công (có dữ liệu)
            // Thêm RefreshIndicator
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(FeedFetched());
              },
              child: ListView.builder(
                itemCount: state.workouts.length,
                itemBuilder: (context, index) {
                  final workout = state.workouts[index];
                  // Dùng widget mới
                  return WorkoutFeedTile(
                    workout: workout,
                    onTap: () {
                      // Mở trang chi tiết khi nhấn vào
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            // Lấy WorkoutBloc từ context của MainShellPage
                            value: context.read<WorkoutBloc>(),
                            child: WorkoutDetailPage(workout: workout),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
