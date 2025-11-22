import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/achievement_model.dart';

abstract class AchievementRemoteDataSource {
  Future<List<UserAchievementModel>> getMyAchievements();
}

class AchievementRemoteDataSourceImpl implements AchievementRemoteDataSource {
  final Dio dio;

  AchievementRemoteDataSourceImpl(this.dio);

  @override
  Future<List<UserAchievementModel>> getMyAchievements() async {
    try {
      final response = await dio.get('/v1/achievements/my');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => UserAchievementModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        message: e.response?.data['message'] ?? 'Lỗi tải thành tựu',
      );
    }
  }
}
