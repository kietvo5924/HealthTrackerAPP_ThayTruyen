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
  final bool isFollowing;

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
    this.isFollowing = false,
  });

  UserProfile copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    DateTime? dateOfBirth,
    String? address,
    String? medicalHistory,
    String? allergies,
    bool? remindWater,
    bool? remindSleep,
    int? goalSteps,
    double? goalWater,
    double? goalSleep,
    int? goalCaloriesBurnt,
    int? goalCaloriesConsumed,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      remindWater: remindWater ?? this.remindWater,
      remindSleep: remindSleep ?? this.remindSleep,
      goalSteps: goalSteps ?? this.goalSteps,
      goalWater: goalWater ?? this.goalWater,
      goalSleep: goalSleep ?? this.goalSleep,
      goalCaloriesBurnt: goalCaloriesBurnt ?? this.goalCaloriesBurnt,
      goalCaloriesConsumed: goalCaloriesConsumed ?? this.goalCaloriesConsumed,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

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
    isFollowing,
  ];
}
