import 'package:equatable/equatable.dart';

class WorkoutComment extends Equatable {
  final int id;
  final String text;
  final DateTime createdAt;
  final String userFullName;
  final int userId;

  const WorkoutComment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userFullName,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, text, createdAt, userFullName, userId];
}
