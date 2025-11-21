import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final DateTime? dateOfBirth;
  final String? address;
  final String? medicalHistory;
  final String? allergies;
  final bool remindWater;
  final bool remindSleep;
  final int goalSteps;
  final double goalWater;
  final double goalSleep;
  final int goalCaloriesBurnt;
  final int goalCaloriesConsumed;
  final int followersCount;
  final int followingCount;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.dateOfBirth,
    this.address,
    this.medicalHistory,
    this.allergies,
    required this.remindWater,
    required this.remindSleep,
    required this.goalSteps,
    required this.goalWater,
    required this.goalSleep,
    required this.goalCaloriesBurnt,
    required this.goalCaloriesConsumed,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phoneNumber,
    role,
    dateOfBirth,
    address,
    medicalHistory,
    allergies,
    remindWater,
    remindSleep,
    goalSteps,
    goalWater,
    goalSleep,
    goalCaloriesBurnt,
    goalCaloriesConsumed,
    followersCount,
    followingCount,
  ];
}
