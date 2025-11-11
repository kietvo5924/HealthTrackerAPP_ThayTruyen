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
  ];
}
