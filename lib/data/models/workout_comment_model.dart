import 'package:health_tracker_app/domain/entities/workout_comment.dart';

class WorkoutCommentModel extends WorkoutComment {
  const WorkoutCommentModel({
    required super.id,
    required super.text,
    required super.createdAt,
    required super.userFullName,
    required super.userId,
  });

  factory WorkoutCommentModel.fromJson(Map<String, dynamic> json) {
    return WorkoutCommentModel(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      userFullName: json['userFullName'],
      userId: json['userId'],
    );
  }
}
