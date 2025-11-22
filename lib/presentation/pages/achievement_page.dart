import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/achievement/achievement_bloc.dart';
import 'package:intl/intl.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AchievementBloc>()..add(AchievementFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thành tựu của tôi'),
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurpleAccent.shade100, Colors.white],
            ),
          ),
          child: BlocBuilder<AchievementBloc, AchievementState>(
            builder: (context, state) {
              if (state.status == AchievementStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == AchievementStatus.failure) {
                return Center(child: Text('Lỗi: ${state.errorMessage}'));
              }
              if (state.achievements.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có thành tựu nào.\nHãy tập luyện để mở khóa!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cột
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // --- SỬA 1: Giảm tỷ lệ để ô cao hơn (0.8 -> 0.7) ---
                  childAspectRatio: 0.7,
                ),
                itemCount: state.achievements.length,
                itemBuilder: (context, index) {
                  final item = state.achievements[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12.0,
                      ), // Giảm padding ngang
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Huy hiệu
                          const CircleAvatar(
                            radius: 28, // Giảm nhẹ bán kính (30 -> 28)
                            backgroundColor: Colors.amber,
                            child: Icon(
                              Icons.emoji_events,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Tên Huy hiệu (Giới hạn 2 dòng)
                          Text(
                            item.achievement.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Mô tả (Dùng Expanded để chiếm chỗ trống còn lại)
                          Expanded(
                            child: Center(
                              // Căn giữa nội dung
                              child: Text(
                                item.achievement.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 3, // Cho phép 3 dòng tối đa
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),
                          // Ngày nhận
                          Text(
                            'Nhận: ${DateFormat('dd/MM/yyyy').format(item.earnedAt)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
