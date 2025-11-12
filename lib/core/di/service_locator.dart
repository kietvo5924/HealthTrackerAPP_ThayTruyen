import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:health_tracker_app/core/network/dio_client.dart';
import 'package:health_tracker_app/core/services/notification_service.dart';
import 'package:health_tracker_app/data/datasources/local/auth_local_data_source.dart';
import 'package:health_tracker_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:health_tracker_app/data/datasources/remote/health_data_remote_data_source.dart';
import 'package:health_tracker_app/data/datasources/remote/notification_remote_data_source.dart';
import 'package:health_tracker_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:health_tracker_app/data/repositories/auth_repository_impl.dart';
import 'package:health_tracker_app/data/repositories/health_data_repository_impl.dart';
import 'package:health_tracker_app/data/repositories/notification_repository_impl.dart';
import 'package:health_tracker_app/data/repositories/user_repository_impl.dart';
import 'package:health_tracker_app/domain/repositories/auth_repository.dart';
import 'package:health_tracker_app/domain/repositories/health_data_repository.dart';
import 'package:health_tracker_app/domain/repositories/notification_repository.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';
import 'package:health_tracker_app/domain/usecases/get_auth_token_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_range_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_user_profile_usecase.dart';
import 'package:health_tracker_app/domain/usecases/log_health_data_usecase.dart';
import 'package:health_tracker_app/domain/usecases/login_usecase.dart';
import 'package:health_tracker_app/domain/usecases/logout_usecase.dart';
import 'package:health_tracker_app/domain/usecases/save_fcm_token_usecase.dart';
import 'package:health_tracker_app/domain/usecases/signup_usecase.dart';
import 'package:health_tracker_app/domain/usecases/update_user_profile_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/login/login_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/signup/signup_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/statistics/statistics_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- THÊM IMPORT MỚI ---
import 'package:location/location.dart';
import 'package:health_tracker_app/presentation/bloc/tracking/tracking_bloc.dart';
import 'package:health_tracker_app/data/datasources/remote/workout_remote_data_source.dart';
import 'package:health_tracker_app/data/repositories/workout_repository_impl.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';
import 'package:health_tracker_app/domain/usecases/get_my_workouts_usecase.dart';
import 'package:health_tracker_app/domain/usecases/log_workout_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
// --- KẾT THÚC THÊM MỚI ---

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // ### Core & External ###
  // 1. SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton(sharedPreferences);

  // 2. Dio
  sl.registerSingleton(Dio());
  sl.registerSingleton(DioClient(sl(), sl()));

  // 3. Firebase
  sl.registerSingleton(FirebaseMessaging.instance);
  sl.registerSingleton(FlutterLocalNotificationsPlugin());

  // --- THÊM MỚI ---
  // 4. Location
  sl.registerSingleton(Location());
  // --- KẾT THÚC THÊM MỚI ---

  // ### DataSources ###
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HealthDataRemoteDataSource>(
    () => HealthDataRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WorkoutRemoteDataSource>(
    () => WorkoutRemoteDataSourceImpl(sl()),
  );

  // ### Repositories ###
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HealthDataRepository>(
    () => HealthDataRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(remoteDataSource: sl()),
  );

  // ### UseCases ###
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));

  sl.registerLazySingleton(() => GetHealthDataUseCase(sl()));
  sl.registerLazySingleton(() => LogHealthDataUseCase(sl()));
  sl.registerLazySingleton(() => GetHealthDataRangeUseCase(sl()));

  sl.registerLazySingleton(() => SaveFcmTokenUseCase(sl()));

  sl.registerLazySingleton(() => GetMyWorkoutsUseCase(sl()));
  sl.registerLazySingleton(() => LogWorkoutUseCase(sl()));

  // ### BLoCs ###
  sl.registerSingleton<AuthBloc>(
    AuthBloc(
      getAuthTokenUseCase: sl(),
      logoutUseCase: sl(),
      saveFcmTokenUseCase: sl(),
    ),
  );
  sl.registerFactory<LoginBloc>(
    () => LoginBloc(loginUseCase: sl(), authBloc: sl()),
  );
  sl.registerFactory<SignupBloc>(() => SignupBloc(signupUseCase: sl()));
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
    ),
  );
  sl.registerFactory<HealthDataBloc>(
    () =>
        HealthDataBloc(getHealthDataUseCase: sl(), logHealthDataUseCase: sl()),
  );
  sl.registerFactory<StatisticsBloc>(
    () => StatisticsBloc(getHealthDataRangeUseCase: sl()),
  );
  sl.registerFactory<WorkoutBloc>(
    () => WorkoutBloc(getMyWorkoutsUseCase: sl(), logWorkoutUseCase: sl()),
  );

  sl.registerFactory<TrackingBloc>(() => TrackingBloc(location: sl()));

  // ### Services ###
  sl.registerLazySingleton(() => NotificationService(sl(), sl()));
}
