import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/social/social_bloc.dart';

class SearchUserPage extends StatelessWidget {
  const SearchUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SocialBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tìm kiếm bạn bè')),
        body: Column(
          children: [
            // 1. Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập tên người dùng...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) {
                  // Gửi event tìm kiếm (Bloc đã có debounce 500ms)
                  context.read<SocialBloc>().add(
                    SocialSearchQueryChanged(value),
                  );
                },
              ),
            ),

            // 2. Danh sách kết quả
            Expanded(
              child: BlocBuilder<SocialBloc, SocialState>(
                builder: (context, state) {
                  if (state.status == SocialStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == SocialStatus.failure) {
                    return Center(child: Text('Lỗi: ${state.errorMessage}'));
                  }

                  if (state.searchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nhập tên để tìm kiếm bạn bè',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.searchResults.length,
                    itemBuilder: (context, index) {
                      final user = state.searchResults[index];

                      // Logic hiển thị nút follow
                      // Lưu ý: Hiện tại API search chưa trả về trạng thái isFollowing
                      // Nên mình sẽ làm nút Follow đơn giản, bấm xong hiện thông báo.
                      final bool isProcessing =
                          state.followStatus == FollowStatus.loading &&
                          state.processingUserId == user.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(color: Colors.blue.shade800),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.email),
                        trailing: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  context.read<SocialBloc>().add(
                                    SocialFollowUser(user.id),
                                  );

                                  // Hiển thị thông báo nhỏ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đã gửi yêu cầu theo dõi ${user.fullName}',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text('Theo dõi'),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
