import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/log_workout_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/tracking/tracking_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:polyline_codec/polyline_codec.dart'; // Import file extension

// === THÊM HÀM VIỆT HÓA ===
String _getVietnameseWorkoutType(WorkoutType type) {
  switch (type) {
    case WorkoutType.RUNNING:
      return 'Chạy bộ';
    case WorkoutType.WALKING:
      return 'Đi bộ';
    case WorkoutType.CYCLING:
      return 'Đạp xe';
    case WorkoutType.SWIMMING:
      return 'Bơi lội';
    case WorkoutType.GYM:
      return 'Tập gym';
    default:
      return 'Khác';
  }
}
// === KẾT THÚC ===

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

  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(TrackingStarted());
  }

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
    final double calories = trackingState.caloriesBurned;

    // 1. Mã hóa List<LatLng> (của latlong2) thành List<List<double>>
    final List<List<double>> pointsToEncode = trackingState.routePoints
        .map((latlng) => [latlng.latitude, latlng.longitude])
        .toList();

    // 2. Mã hóa thành chuỗi Polyline
    final String routePolyline = PolylineCodec.encode(pointsToEncode);

    final int durationInMinutes = (duration / 60).ceil();

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
                  Text('Calo: ${calories.toStringAsFixed(0)} kcal'),
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
                        // === SỬA (VIỆT HÓA) ===
                        child: Text(_getVietnameseWorkoutType(type)),
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
                    if (state.isSubmitting) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        final params = LogWorkoutParams(
                          workoutType: _selectedType,
                          // Dùng biến đã tính
                          durationInMinutes: durationInMinutes,
                          startedAt: DateTime.now().toUtc(),
                          caloriesBurned: calories,
                          distanceInKm: distance,
                          routePolyline: routePolyline,
                        );
                        workoutBloc.add(WorkoutAdded(params));
                        // Không đóng dialog ở đây. Đợi thành công để pop qua listener.
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
    // === XÓA BLOCPROVIDER(CREATE: ...) Ở ĐÂY ===
    return Scaffold(
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
            // === SỬA (LỖI KHÔNG TỰ OUT TRANG) ===
            listenWhen: (previous, current) {
              // Lắng nghe khi:
              // - isSubmitting thay đổi
              // - hoặc status chuyển sang success (một số flow không bật cờ isSubmitting)
              // - hoặc có lỗi submit thay đổi để hiển thị thông báo
              final submittingChanged =
                  previous.isSubmitting != current.isSubmitting;
              final becameSuccess =
                  // Khi trạng thái tổng thể chuyển sang success và không còn submitting
                  previous.status != current.status &&
                  current.status == WorkoutStatus.success &&
                  current.isSubmitting == false;
              final errorChanged =
                  previous.submissionError != current.submissionError;
              return submittingChanged || becameSuccess || errorChanged;
            },
            listener: (context, workoutState) {
              // 1. Kiểm tra lỗi TRƯỚC
              if (workoutState.submissionError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lỗi lưu bài tập: ${workoutState.submissionError}',
                    ),
                  ),
                );
              }
              // 2. Thành công: status success, không submitting, không lỗi
              else if (!workoutState.isSubmitting &&
                  workoutState.status == WorkoutStatus.success) {
                // Cập nhật Home sau khi lưu thành công
                final workoutDate = DateTime.now();
                context.read<HealthDataBloc>().add(
                  HealthDataFetched(workoutDate.toLocal()),
                );

                // Pop dialog (nếu đang mở) rồi pop trang Tracking
                final nav = Navigator.of(context);
                final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
                final hasOverlayOnTop = !isCurrent;
                if (hasOverlayOnTop) {
                  if (nav.canPop()) nav.pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (nav.canPop()) nav.pop();
                  });
                } else {
                  if (nav.canPop()) nav.pop();
                }
              }
            },
            // === KẾT THÚC SỬA ===
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
                          Column(
                            children: [
                              Text(
                                'Calo',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                state.caloriesBurned.toStringAsFixed(0),
                                style: Theme.of(context).textTheme.titleLarge,
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
            heroTag: 'pause_button',
            onPressed: () => bloc.add(TrackingPaused()),
            child: const Icon(Icons.pause),
          ),
          FloatingActionButton(
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
            heroTag: 'play_button',
            onPressed: () => bloc.add(TrackingResumed()),
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
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
