import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/usecases/get_user_profile_usecase.dart';
import 'package:health_tracker_app/domain/usecases/update_user_profile_usecase.dart';
import 'package:health_tracker_app/data/models/user_profile_model.dart'; // Để dùng tạm

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       super(const ProfileState()) {
    on<ProfileFetched>(_onProfileFetched);
    on<ProfileFullNameChanged>(_onFullNameChanged);
    on<ProfilePhoneNumberChanged>(_onPhoneNumberChanged);
    on<ProfileDateOfBirthChanged>(_onDateOfBirthChanged);
    on<ProfileAddressChanged>(_onAddressChanged);
    on<ProfileSubmitted>(_onProfileSubmitted);
    on<ProfileMedicalHistoryChanged>(_onMedicalHistoryChanged);
    on<ProfileAllergiesChanged>(_onAllergiesChanged);
  }

  Future<void> _onProfileFetched(
    ProfileFetched event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _getUserProfileUseCase(NoParams());
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (profile) {
        emit(
          state.copyWith(status: ProfileStatus.success, userProfile: profile),
        );
      },
    );
  }

  // Các hàm cập nhật state tạm thời
  void _onFullNameChanged(
    ProfileFullNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state.userProfile == null) return;
    emit(
      state.copyWith(
        userProfile: UserProfileModel(
          // Dùng Model vì Entity không có copyWith
          id: state.userProfile!.id,
          email: state.userProfile!.email,
          role: state.userProfile!.role,
          fullName: event.fullName, // Thay đổi
          phoneNumber: state.userProfile!.phoneNumber,
          dateOfBirth: state.userProfile!.dateOfBirth,
          address: state.userProfile!.address,
        ),
      ),
    );
  }

  void _onPhoneNumberChanged(
    ProfilePhoneNumberChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state.userProfile == null) return;
    emit(
      state.copyWith(
        userProfile: UserProfileModel(
          id: state.userProfile!.id,
          email: state.userProfile!.email,
          role: state.userProfile!.role,
          fullName: state.userProfile!.fullName,
          phoneNumber: event.phoneNumber, // Thay đổi
          dateOfBirth: state.userProfile!.dateOfBirth,
          address: state.userProfile!.address,
        ),
      ),
    );
  }

  void _onDateOfBirthChanged(
    ProfileDateOfBirthChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state.userProfile == null) return;
    emit(
      state.copyWith(
        userProfile: UserProfileModel(
          id: state.userProfile!.id,
          email: state.userProfile!.email,
          role: state.userProfile!.role,
          fullName: state.userProfile!.fullName,
          phoneNumber: state.userProfile!.phoneNumber,
          dateOfBirth: event.dateOfBirth, // Thay đổi
          address: state.userProfile!.address,
        ),
      ),
    );
  }

  void _onAddressChanged(
    ProfileAddressChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state.userProfile == null) return;
    emit(
      state.copyWith(
        userProfile: UserProfileModel(
          id: state.userProfile!.id,
          email: state.userProfile!.email,
          role: state.userProfile!.role,
          fullName: state.userProfile!.fullName,
          phoneNumber: state.userProfile!.phoneNumber,
          dateOfBirth: state.userProfile!.dateOfBirth,
          address: event.address, // Thay đổi
        ),
      ),
    );
  }

  Future<void> _onProfileSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.userProfile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await _updateUserProfileUseCase(state.userProfile!);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedProfile) {
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            userProfile: updatedProfile,
          ),
        );
      },
    );
  }

  void _onMedicalHistoryChanged(
    ProfileMedicalHistoryChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state.userProfile == null) return;
    emit(
      state.copyWith(
        userProfile: UserProfileModel(
          id: state.userProfile!.id,
          email: state.userProfile!.email,
          role: state.userProfile!.role,
          fullName: state.userProfile!.fullName,
          phoneNumber: state.userProfile!.phoneNumber,
          dateOfBirth: state.userProfile!.dateOfBirth,
          address: state.userProfile!.address,
          medicalHistory: event.medicalHistory, // Thay đổi
          allergies: state.userProfile!.allergies,
        ),
      ),
    );
  }

  void _onAllergiesChanged(
    ProfileAllergiesChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state.userProfile == null) return;
    emit(
      state.copyWith(
        userProfile: UserProfileModel(
          id: state.userProfile!.id,
          email: state.userProfile!.email,
          role: state.userProfile!.role,
          fullName: state.userProfile!.fullName,
          phoneNumber: state.userProfile!.phoneNumber,
          dateOfBirth: state.userProfile!.dateOfBirth,
          address: state.userProfile!.address,
          medicalHistory: state.userProfile!.medicalHistory,
          allergies: event.allergies, // Thay đổi
        ),
      ),
    );
  }
}
