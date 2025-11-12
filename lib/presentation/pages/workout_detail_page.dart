import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_tracker_app/core/utils/string_extensions.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:polyline_codec/polyline_codec.dart';

class WorkoutDetailPage extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailPage({super.key, required this.workout});

  // Hàm giải mã (decode) chuỗi polyline
  List<LatLng> _decodePolyline() {
    if (workout.routePolyline == null || workout.routePolyline!.isEmpty) {
      return [];
    }
    try {
      final List<List<num>> points = PolylineCodec.decode(
        workout.routePolyline!,
      );
      return points
          .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
          .toList();
    } catch (e) {
      print('Lỗi giải mã Polyline: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> routePoints = _decodePolyline();

    // Tính toán bounds (khung) của bản đồ
    LatLngBounds? mapBounds;
    if (routePoints.isNotEmpty) {
      mapBounds = LatLngBounds.fromPoints(routePoints);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          workout.workoutType.toString().split('.').last.capitalize(),
        ),
      ),
      body: Column(
        children: [
          // 1. Bản đồ (chỉ hiển thị nếu có tuyến đường)
          if (routePoints.isNotEmpty && mapBounds != null)
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: mapBounds,
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
                        points: routePoints,
                        color: Colors.blue,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Hiển thị nếu không có bản đồ (ví dụ: tập GYM)
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

          // 2. Chi tiết thông số
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMEEEEd().add_Hm().format(
                    workout.startedAt.toLocal(),
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatTile(
                      label: 'Quãng đường',
                      value:
                          '${workout.distanceInKm?.toStringAsFixed(2) ?? '0'}',
                      unit: 'km',
                    ),
                    _StatTile(
                      label: 'Thời gian',
                      value: '${workout.durationInMinutes} phút',
                      unit: '',
                    ),
                    _StatTile(
                      label: 'Calo',
                      value: '${workout.caloriesBurned?.toInt() ?? 'N/A'}',
                      unit: 'kcal',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget private cho ô thông số
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
