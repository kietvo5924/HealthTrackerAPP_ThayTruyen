import 'package:flutter/material.dart';
import 'package:health_tracker_app/presentation/widgets/circular_progress_painter.dart';

class CircularHealthTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String unit;
  final double progress; // 0.0 đến 1.0
  final Color progressColor;
  final VoidCallback onTap;

  const CircularHealthTile({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.unit,
    required this.progress,
    required this.progressColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          // --- SỬA LỖI (Thêm căn giữa) ---
          crossAxisAlignment: CrossAxisAlignment.center,
          // --- KẾT THÚC SỬA LỖI ---
          children: [
            // Vòng tròn tiến độ
            SizedBox(
              width: 70,
              height: 70,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: progress,
                  backgroundColor: Colors.grey.shade200,
                  progressColor: progressColor,
                  strokeWidth: 8,
                ),
                // Icon ở giữa
                child: Center(
                  child: Icon(icon, color: progressColor, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // --- SỬA LỖI (Thêm Expanded) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Thêm căn giữa
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    // Thêm để tránh tràn text
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // --- KẾT THÚC SỬA LỖI ---
          ],
        ),
      ),
    );
  }
}
