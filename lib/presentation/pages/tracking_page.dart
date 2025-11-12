import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/log_workout_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/tracking/tracking_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:health_tracker_app/core/utils/string_extensions.dart'; // Import file extension

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final MapController _mapController = MapController();
  final Distance _distanceCalculator =
      const Distance(); // Dùng để tính quãng đường
  WorkoutType _selectedType = WorkoutType.RUNNING; // Mặc định là Chạy bộ

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  double _calculateDistance(List<LatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _distanceCalculator.as(
        LengthUnit.Kilometer,
        points[i],
        points[i + 1],
      );
    }
    return totalDistance;
  }

  void _showSaveDialog(BuildContext context, TrackingState trackingState) {
    final workoutBloc = context.read<WorkoutBloc>();
    final distance = _calculateDistance(trackingState.routePoints);
    final duration = trackingState.durationInSeconds;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Hoàn thành!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thời gian: ${_formatDuration(duration)}'),
                  Text('Quãng đường: ${distance.toStringAsFixed(2)} km'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WorkoutType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Loại bài tập',
                      border: OutlineInputBorder(),
                    ),
                    items: WorkoutType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.toString().split('.').last.capitalize(),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Hủy
                    Navigator.of(context).pop(); // Đóng trang tracking
                  },
                  child: const Text('Bỏ qua'),
                ),
                BlocBuilder<WorkoutBloc, WorkoutState>(
                  bloc: workoutBloc,
                  builder: (context, state) {
                    return state.isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              final params = LogWorkoutParams(
                                workoutType: _selectedType,
                                durationInMinutes: (duration / 60).round(),
                                startedAt: DateTime.now().toUtc(),
                                caloriesBurned: null, // (Có thể tính sau)
                                distanceInKm: distance,
                                routePolyline: null, // (Sẽ thêm polyline sau)
                              );
                              workoutBloc.add(WorkoutAdded(params));
                              Navigator.of(dialogContext).pop(); // Đóng dialog
                            },
                            child: const Text('Lưu'),
                          );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrackingBloc>()..add(TrackingStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Bắt đầu bài tập')),
        body: BlocConsumer<TrackingBloc, TrackingState>(
          listener: (context, state) {
            // Chỉ di chuyển camera NẾU ĐANG TRACKING
            if (state.status == TrackingStatus.tracking &&
                state.currentLocation != null) {
              _mapController.move(
                LatLng(
                  state.currentLocation!.latitude!,
                  state.currentLocation!.longitude!,
                ),
                16.0,
              );
            }
            // Khi bấm Stop, hiển thị Dialog
            if (state.status == TrackingStatus.success) {
              _showSaveDialog(context, state);
            }
          },
          builder: (context, state) {
            // 1. Trạng thái Loading hoặc Lỗi
            if (state.status == TrackingStatus.initial ||
                state.status == TrackingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == TrackingStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Lỗi: ${state.errorMessage}\nVui lòng kiểm tra quyền GPS và bật Dịch vụ Vị trí.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // 2. Trạng thái Tracking/Paused/Success (Hiển thị bản đồ)
            final double bottomPadding = MediaQuery.of(context).padding.bottom;

            return BlocListener<WorkoutBloc, WorkoutState>(
              listener: (context, workoutState) {
                // Khi lưu workout thành công, tự động đóng trang
                if (workoutState.isSubmitting == false &&
                    workoutState.submissionError == null) {
                  // Đảm bảo nó chỉ pop sau khi submit
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
                // Khi lưu thất bại (của WorkoutBloc)
                if (workoutState.submissionError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Lỗi lưu bài tập: ${workoutState.submissionError}',
                      ),
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  // Lớp 1: Bản đồ
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        state.currentLocation!.latitude!,
                        state.currentLocation!.longitude!,
                      ),
                      initialZoom: 16.0,
                    ),
                    children: [
                      // Layer ảnh bản đồ
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.health_tracker_app_new',
                      ),
                      // Layer vẽ đường đi
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: state.routePoints,
                            color: Colors.blue,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                      // Layer icon vị trí hiện tại
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                              state.currentLocation!.latitude!,
                              state.currentLocation!.longitude!,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Lớp 2: Thông số (Timer, Distance)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Thời gian',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  _formatDuration(state.durationInSeconds),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Quãng đường',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${_calculateDistance(state.routePoints).toStringAsFixed(2)} km',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Lớp 3: Nút điều khiển
                  Positioned(
                    bottom: 20 + bottomPadding,
                    left: 0,
                    right: 0,
                    child: _buildControlsPanel(context, state.status),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget cho các nút Play/Pause/Stop
  Widget _buildControlsPanel(BuildContext context, TrackingStatus status) {
    final bloc = context.read<TrackingBloc>();

    if (status == TrackingStatus.tracking) {
      // Đang chạy: Hiển thị 2 nút (Pause, Stop)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            // --- SỬA LỖI 2 (Hero) ---
            heroTag: 'pause_button',
            onPressed: () => bloc.add(TrackingPaused()),
            child: const Icon(Icons.pause),
          ),
          FloatingActionButton(
            // --- SỬA LỖI 2 (Hero) ---
            heroTag: 'stop_button',
            onPressed: () => bloc.add(TrackingStopped()),
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          ),
        ],
      );
    } else {
      // Đang dừng (Paused): Hiển thị 2 nút (Play, Stop)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            // --- SỬA LỖI 2 (Hero) ---
            heroTag: 'play_button',
            onPressed: () => bloc.add(TrackingResumed()),
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
            // --- SỬA LỖI 2 (Hero) ---
            heroTag: 'stop_button_paused',
            onPressed: () => bloc.add(TrackingStopped()),
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          ),
        ],
      );
    }
  }
}
