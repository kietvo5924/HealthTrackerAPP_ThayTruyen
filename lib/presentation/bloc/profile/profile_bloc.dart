import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/data/models/user_goals_request_model.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/usecases/get_user_profile_usecase.dart';
import 'package:health_tracker_app/domain/usecases/update_notification_settings_usecase.dart';
import 'package:health_tracker_app/domain/usecases/update_user_goals_usecase.dart';
import 'package:health_tracker_app/domain/usecases/update_user_profile_usecase.dart';
import 'package:health_tracker_app/data/models/user_profile_model.dart'; // Để dùng tạm

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UpdateNotificationSettingsUseCase _updateNotificationSettingsUseCase;
  final UpdateUserGoalsUseCase _updateUserGoalsUseCase;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UpdateNotificationSettingsUseCase
    updateNotificationSettingsUseCase,
    required UpdateUserGoalsUseCase updateUserGoalsUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _updateNotificationSettingsUseCase = updateNotificationSettingsUseCase,
       _updateUserGoalsUseCase = updateUserGoalsUseCase,
       super(const ProfileState()) {
    on<ProfileFetched>(_onProfileFetched);
    on<ProfileFullNameChanged>(_onFullNameChanged);
    on<ProfilePhoneNumberChanged>(_onPhoneNumberChanged);
    on<ProfileDateOfBirthChanged>(_onDateOfBirthChanged);
    on<ProfileAddressChanged>(_onAddressChanged);
    on<ProfileSubmitted>(_onProfileSubmitted);
    on<ProfileMedicalHistoryChanged>(_onMedicalHistoryChanged);
    on<ProfileAllergiesChanged>(_onAllergiesChanged);
    on<ProfileNotificationSettingsChanged>(_onNotificationSettingsChanged);
    on<ProfileGoalChanged>(_onGoalChanged);
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
          remindWater: state.userProfile!.remindWater,
          remindSleep: state.userProfile!.remindSleep,
          goalSteps: state.userProfile!.goalSteps,
          goalWater: state.userProfile!.goalWater,
          goalSleep: state.userProfile!.goalSleep,
          goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
          goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
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
          remindWater: state.userProfile!.remindWater,
          remindSleep: state.userProfile!.remindSleep,
          goalSteps: state.userProfile!.goalSteps,
          goalWater: state.userProfile!.goalWater,
          goalSleep: state.userProfile!.goalSleep,
          goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
          goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
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
          remindWater: state.userProfile!.remindWater,
          remindSleep: state.userProfile!.remindSleep,
          goalSteps: state.userProfile!.goalSteps,
          goalWater: state.userProfile!.goalWater,
          goalSleep: state.userProfile!.goalSleep,
          goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
          goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
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
          remindWater: state.userProfile!.remindWater,
          remindSleep: state.userProfile!.remindSleep,
          goalSteps: state.userProfile!.goalSteps,
          goalWater: state.userProfile!.goalWater,
          goalSleep: state.userProfile!.goalSleep,
          goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
          goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
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
          remindWater: state.userProfile!.remindWater,
          remindSleep: state.userProfile!.remindSleep,
          goalSteps: state.userProfile!.goalSteps,
          goalWater: state.userProfile!.goalWater,
          goalSleep: state.userProfile!.goalSleep,
          goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
          goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
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
          remindWater: state.userProfile!.remindWater,
          remindSleep: state.userProfile!.remindSleep,
          goalSteps: state.userProfile!.goalSteps,
          goalWater: state.userProfile!.goalWater,
          goalSleep: state.userProfile!.goalSleep,
          goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
          goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
        ),
      ),
    );
  }

  Future<void> _onNotificationSettingsChanged(
    ProfileNotificationSettingsChanged event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.userProfile == null) return;

    // 1. Cập nhật UI ngay lập tức (Lạc quan)
    final optimisticProfile = UserProfileModel(
      id: state.userProfile!.id,
      email: state.userProfile!.email,
      role: state.userProfile!.role,
      fullName: state.userProfile!.fullName,
      phoneNumber: state.userProfile!.phoneNumber,
      dateOfBirth: state.userProfile!.dateOfBirth,
      address: state.userProfile!.address,
      medicalHistory: state.userProfile!.medicalHistory,
      allergies: state.userProfile!.allergies,
      // Cập nhật giá trị mới
      remindWater: event.remindWater,
      remindSleep: event.remindSleep,
      goalSteps: state.userProfile!.goalSteps,
      goalWater: state.userProfile!.goalWater,
      goalSleep: state.userProfile!.goalSleep,
      goalCaloriesBurnt: state.userProfile!.goalCaloriesBurnt,
      goalCaloriesConsumed: state.userProfile!.goalCaloriesConsumed,
    );

    emit(
      state.copyWith(
        userProfile: optimisticProfile,
        status: ProfileStatus.updating,
      ),
    );

    // 2. Gọi API
    final result = await _updateNotificationSettingsUseCase(
      NotificationSettingsRequestModel(
        remindWater: event.remindWater,
        remindSleep: event.remindSleep,
      ),
    );

    // 3. Xử lý kết quả
    result.fold(
      (failure) {
        // Nếu lỗi, quay về trạng thái cũ và báo lỗi
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
            userProfile: state.userProfile, // Quay lại profile cũ
          ),
        );
      },
      (updatedProfile) {
        // Nếu thành công, xác nhận state
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            userProfile: updatedProfile,
          ),
        );
      },
    );
  }

  Future<void> _onGoalChanged(
    ProfileGoalChanged event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.userProfile == null) return;

    // 1. Cập nhật UI ngay lập tức (Lạc quan)
    final optimisticProfile = UserProfileModel(
      id: state.userProfile!.id,
      email: state.userProfile!.email,
      role: state.userProfile!.role,
      fullName: state.userProfile!.fullName,
      phoneNumber: state.userProfile!.phoneNumber,
      dateOfBirth: state.userProfile!.dateOfBirth,
      address: state.userProfile!.address,
      medicalHistory: state.userProfile!.medicalHistory,
      allergies: state.userProfile!.allergies,
      remindWater: state.userProfile!.remindWater,
      remindSleep: state.userProfile!.remindSleep,

      // Cập nhật giá trị mới (nếu null thì dùng giá trị cũ)
      goalSteps: event.goalSteps ?? state.userProfile!.goalSteps,
      goalWater: event.goalWater ?? state.userProfile!.goalWater,
      goalSleep: event.goalSleep ?? state.userProfile!.goalSleep,
      goalCaloriesBurnt:
          event.goalCaloriesBurnt ?? state.userProfile!.goalCaloriesBurnt,
      goalCaloriesConsumed:
          event.goalCaloriesConsumed ?? state.userProfile!.goalCaloriesConsumed,
    );

    // Tạm thời emit state mới
    emit(state.copyWith(userProfile: optimisticProfile));

    // 2. Gọi API (chỉ gửi những giá trị đã thay đổi)
    final result = await _updateUserGoalsUseCase(
      UserGoalsRequestModel(
        goalSteps: event.goalSteps,
        goalWater: event.goalWater,
        goalSleep: event.goalSleep,
        goalCaloriesBurnt: event.goalCaloriesBurnt,
        goalCaloriesConsumed: event.goalCaloriesConsumed,
      ),
    );

    // 3. Xử lý kết quả
    result.fold(
      (failure) {
        // Nếu lỗi, quay về trạng thái cũ và báo lỗi
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
            userProfile: state.userProfile, // Quay lại profile cũ
          ),
        );
      },
      (updatedProfile) {
        // Nếu thành công, xác nhận state
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            userProfile: updatedProfile, // Dùng profile mới nhất từ server
          ),
        );
      },
    );
  }
}
