import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/feed/feed_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:health_tracker_app/presentation/pages/search_user_page.dart'; // Import trang tìm kiếm
import 'package:health_tracker_app/presentation/pages/workout_detail_page.dart';
import 'package:health_tracker_app/presentation/widgets/workout_feed_tile.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeedBloc>()..add(FeedFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bảng tin'),
          actions: [
            // --- THÊM NÚT TÌM KIẾM ---
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Tìm bạn bè',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchUserPage()),
                );
              },
            ),
            // -------------------------
          ],
        ),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
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

            if (state.status == FeedStatus.loading ||
                state.status == FeedStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == FeedStatus.success && state.workouts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có hoạt động nào.\nHãy follow thêm bạn bè!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Nút gợi ý tìm bạn
                    OutlinedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Tìm bạn bè ngay'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchUserPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(FeedFetched());
              },
              child: ListView.builder(
                itemCount: state.workouts.length,
                itemBuilder: (context, index) {
                  final workout = state.workouts[index];
                  return WorkoutFeedTile(
                    workout: workout,
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
