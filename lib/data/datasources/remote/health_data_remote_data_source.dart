import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/health_data_log_request_model.dart';
import 'package:health_tracker_app/data/models/health_data_model.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:intl/intl.dart';

abstract class HealthDataRemoteDataSource {
  Future<HealthDataModel> getHealthData(DateTime date);
  Future<HealthDataModel> logHealthData(HealthData healthData);

  Future<List<HealthDataModel>> getHealthDataRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class HealthDataRemoteDataSourceImpl implements HealthDataRemoteDataSource {
  final Dio dio;

  HealthDataRemoteDataSourceImpl(this.dio);

  @override
  Future<HealthDataModel> getHealthData(DateTime date) async {
    // Format ngày thành YYYY-MM-DD
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    try {
      final response = await dio.get('/health-data/$dateString');

      if (response.statusCode == 200) {
        // API trả về 200 OK với object data (hoặc null nếu không có)
        if (response.data == null || response.data == "") {
          // Nếu backend trả về null/rỗng, ta tự tạo object rỗng cho ngày đó
          return HealthDataModel(date: date);
        }
        return HealthDataModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lấy dữ liệu thất bại',
        );
      }
    } on DioException catch (e) {
      // Bắt lỗi 404 hoặc lỗi khác
      if (e.response?.statusCode == 404 || e.response?.statusCode == 200) {
        // Nếu backend trả về 404 hoặc 200 (nhưng rỗng),
        // chúng ta coi đó là "không có dữ liệu" và trả về object rỗng
        return HealthDataModel(date: date);
      }
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }

  @override
  Future<HealthDataModel> logHealthData(HealthData healthData) async {
    // 1. Chuyển Entity sang DTO
    final requestModel = HealthDataLogRequestModel.fromEntity(healthData);

    try {
      // 2. Gọi API POST
      final response = await dio.post(
        '/health-data',
        data: requestModel.toJson(),
      );

      if (response.statusCode == 200) {
        // 3. Trả về HealthDataModel đã cập nhật
        return HealthDataModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Ghi dữ liệu thất bại',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }

  @override
  Future<List<HealthDataModel>> getHealthDataRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final response = await dio.get(
        '/health-data/range',
        queryParameters: {'startDate': start, 'endDate': end},
      );

      if (response.statusCode == 200) {
        // API trả về một List, chúng ta map qua nó
        return (response.data as List)
            .map((json) => HealthDataModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lấy dữ liệu (range) thất bại',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }
}
