import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/feed/feed_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:health_tracker_app/presentation/pages/search_user_page.dart';
import 'package:health_tracker_app/presentation/pages/workout_detail_page.dart';
import 'package:health_tracker_app/presentation/widgets/workout_feed_tile.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // 1. Khai báo biến Bloc và Controller
  late final FeedBloc _feedBloc;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 2. Khởi tạo Bloc và gọi sự kiện Fetch ngay tại đây
    _feedBloc = sl<FeedBloc>()..add(FeedFetched());

    // Lắng nghe cuộn trang
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 3. Nhớ đóng Bloc và Controller khi thoát màn hình
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _feedBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      // 4. Gọi trực tiếp biến _feedBloc, KHÔNG dùng context.read nữa
      _feedBloc.add(FeedScrolled());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    // 5. Dùng BlocProvider.value để cung cấp biến _feedBloc đã tạo xuống cây widget con
    return BlocProvider.value(
      value: _feedBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bảng tin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Tìm bạn bè',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchUserPage()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            if (state.status == FeedStatus.failure && state.workouts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${state.errorMessage}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _feedBloc.add(FeedFetched()); // Dùng trực tiếp biến
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state.status == FeedStatus.initial ||
                (state.status == FeedStatus.loading &&
                    state.workouts.isEmpty)) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.workouts.isEmpty) {
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
                _feedBloc.add(FeedFetched()); // Dùng trực tiếp biến
              },
              child: ListView.builder(
                controller: _scrollController,
                // Luôn cộng thêm 1 item cho loading indicator khi chưa hết dữ liệu
                itemCount: state.hasReachedMax
                    ? state.workouts.length
                    : state.workouts.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.workouts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

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
