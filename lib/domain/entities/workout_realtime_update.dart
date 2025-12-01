import 'package:equatable/equatable.dart';

class WorkoutRealtimeUpdate extends Equatable {
  final int workoutId;
  final int likeCount;
  final int commentCount;
  final String eventType;
  final int? actorId;
  final String? actorName;

  const WorkoutRealtimeUpdate({
    required this.workoutId,
    required this.likeCount,
    required this.commentCount,
    required this.eventType,
    this.actorId,
    this.actorName,
  });

  factory WorkoutRealtimeUpdate.fromJson(Map<String, dynamic> json) {
    return WorkoutRealtimeUpdate(
      workoutId: (json['workoutId'] as num).toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      eventType: json['eventType'] as String? ?? 'UNKNOWN',
      actorId: (json['actorId'] as num?)?.toInt(),
      actorName: json['actorName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'eventType': eventType,
      'actorId': actorId,
      'actorName': actorName,
    };
  }

  @override
  List<Object?> get props => [
    workoutId,
    likeCount,
    commentCount,
    eventType,
    actorId,
    actorName,
  ];
}
