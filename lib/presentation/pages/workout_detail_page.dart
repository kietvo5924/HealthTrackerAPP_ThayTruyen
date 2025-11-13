// --- THAY THẾ TOÀN BỘ FILE workout_detail_page.dart BẰNG CODE NÀY ---

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart'; // Thư viện của bạn
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/core/utils/string_extensions.dart'; // Import của bạn
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/entities/workout_comment.dart';
import 'package:health_tracker_app/domain/usecases/add_workout_comment_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_workout_comments_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart'; // Thư viện của bạn
import 'package:polyline_codec/polyline_codec.dart'; // Thư viện của bạn

// 1. Chuyển thành StatefulWidget
class WorkoutDetailPage extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailPage({super.key, required this.workout});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  // 2. Thêm các biến State cho bình luận
  final _getCommentsUseCase = sl<GetWorkoutCommentsUseCase>();
  final _addCommentUseCase = sl<AddWorkoutCommentUseCase>();
  final _commentController = TextEditingController();

  late Future<List<WorkoutComment>> _commentsFuture;
  bool _isSending = false;

  // 3. Thêm biến State cho bản đồ (từ code của bạn)
  List<LatLng> _routePoints = [];
  LatLngBounds? _mapBounds;

  @override
  void initState() {
    super.initState();
    // 4. Tải bình luận và giải mã polyline khi mở trang
    _commentsFuture = _fetchComments();
    _decodePolyline();
  }

  // 5. Hàm tải bình luận
  Future<List<WorkoutComment>> _fetchComments() async {
    final result = await _getCommentsUseCase(widget.workout.id);
    return result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bình luận: ${failure.message}')),
        );
      }
      return [];
    }, (comments) => comments);
  }

  // 6. Hàm gửi bình luận
  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || _isSending) return;

    // 1. Bật Spinner
    setState(() {
      _isSending = true;
    });

    final result = await _addCommentUseCase(
      AddCommentParams(
        workoutId: widget.workout.id,
        text: _commentController.text.trim(),
      ),
    );

    // 2. Xử lý kết quả
    result.fold(
      (failure) {
        // --- TRƯỜNG HỢP THẤT BẠI ---
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi gửi bình luận: ${failure.message}')),
          );

          // Tắt Spinner
          setState(() {
            _isSending = false;
          });
        }
      },
      (newComment) {
        // --- TRƯỜNG HỢP THÀNH CÔNG ---
        _commentController.clear();
        if (mounted) {
          // Cập nhật BLoC (để FeedPage cập nhật)
          // Dòng này giờ sẽ không lỗi vì bạn đã sửa navigation
          context.read<WorkoutBloc>().add(WorkoutsFetched());

          // Cập nhật UI: Tải lại list VÀ Tắt Spinner
          // (Gộp chung trong 1 setState)
          setState(() {
            _commentsFuture = _fetchComments();
            _isSending = false; // <-- SỬA LỖI Ở ĐÂY
          });
        }
      },
    );
  }

  // 7. Hàm giải mã Polyline (TỪ CODE CỦA BẠN)
  void _decodePolyline() {
    if (widget.workout.routePolyline == null ||
        widget.workout.routePolyline!.isEmpty) {
      return;
    }
    try {
      final List<List<num>> points = PolylineCodec.decode(
        widget.workout.routePolyline!,
      );
      final pointsLatLng = points
          .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
          .toList();

      if (pointsLatLng.isNotEmpty) {
        setState(() {
          _routePoints = pointsLatLng;
          _mapBounds = LatLngBounds.fromPoints(pointsLatLng);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi giải mã Polyline: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Dùng hàm capitalize từ code của bạn
          'Chi tiết ${widget.workout.workoutType.toString().split('.').last.capitalize()}',
        ),
      ),
      // 8. Dùng ListView thay vì Column (để cuộn khi có nhiều bình luận)
      body: ListView(
        children: [
          // 9. BẢN ĐỒ (Sử dụng code flutter_map của bạn)
          if (_routePoints.isNotEmpty && _mapBounds != null)
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: _mapBounds!,
                    padding: const EdgeInsets.all(25.0), // Đệm 25px
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.health_tracker_app_new',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Hiển thị nếu không có bản đồ (code của bạn)
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'Không có dữ liệu bản đồ cho bài tập này',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          // 10. THÔNG TIN (Kết hợp code của bạn và tôi)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thực hiện bởi: ${widget.workout.userFullName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  // Thêm 'vi_VN' cho chuẩn
                  'Vào lúc: ${DateFormat.yMd('vi_VN').add_Hm().format(widget.workout.startedAt.toLocal())}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                // Hàng thông số (từ code của bạn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatTile(
                      label: 'Quãng đường',
                      value:
                          // ignore: unnecessary_string_interpolations
                          '${widget.workout.distanceInKm?.toStringAsFixed(2) ?? '0'}',
                      unit: 'km',
                    ),
                    _StatTile(
                      label: 'Thời gian',
                      value: '${widget.workout.durationInMinutes}',
                      unit: 'phút',
                    ),
                    _StatTile(
                      label: 'Calo',
                      value:
                          '${widget.workout.caloriesBurned?.toInt() ?? 'N/A'}',
                      unit: 'kcal',
                    ),
                  ],
                ),
                const Divider(height: 40),

                // 11. PHẦN BÌNH LUẬN (Từ code của tôi)
                Text(
                  'Bình luận',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildCommentInput(),
                const SizedBox(height: 16),
                _buildCommentList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 12. Widget nhập bình luận
  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Viết bình luận...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => _postComment(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: _isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send),
          onPressed: _postComment,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // 13. Widget danh sách bình luận
  Widget _buildCommentList() {
    return FutureBuilder<List<WorkoutComment>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có bình luận nào.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final comments = snapshot.data!;
        return ListView.builder(
          itemCount: comments.length,
          shrinkWrap: true, // Quan trọng khi lồng ListView
          physics:
              const NeverScrollableScrollPhysics(), // Quan trọng khi lồng ListView
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  comment.userFullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.text),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMd(
                        'vi_VN',
                      ).add_Hm().format(comment.createdAt.toLocal()),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 14. Widget _StatTile (SỬ DỤNG PHIÊN BẢN CỦA BẠN)
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        if (unit.isNotEmpty)
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
