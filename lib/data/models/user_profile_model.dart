import 'package:health_tracker_app/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.role,
    super.dateOfBirth,
    super.address,
    super.medicalHistory,
    super.allergies,
    required super.remindWater,
    required super.remindSleep,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
      remindWater: json['remindWater'] ?? true,
      remindSleep: json['remindSleep'] ?? true,
    );
  }

  // Dùng để gửi data lên API (cho `PUT /api/users/me`)
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String().split(
        'T',
      )[0], // Gửi YYYY-MM-DD
      'address': address,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
    };
  }
}
