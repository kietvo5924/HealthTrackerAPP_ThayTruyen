import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/add_meal_item_request_model.dart';
import 'package:health_tracker_app/data/models/food_model.dart';
import 'package:health_tracker_app/data/models/meal_model.dart';
import 'package:intl/intl.dart';

abstract class NutritionRemoteDataSource {
  /// API: GET /api/nutrition/food?query=...
  Future<List<FoodModel>> searchFood(String query);

  /// API: GET /api/nutrition/meals?date=...
  Future<List<MealModel>> getMealsForDate(DateTime date);

  /// API: POST /api/nutrition/meals/item
  Future<MealModel> addFoodToMeal(AddMealItemRequestModel request);

  /// API: DELETE /api/nutrition/meals/item/{itemId}
  Future<void> deleteMealItem(int mealItemId);
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  final Dio dio;

  NutritionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<FoodModel>> searchFood(String query) async {
    try {
      final response = await dio.get(
        '/nutrition/food',
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => FoodModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Tìm kiếm thất bại',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<MealModel>> getMealsForDate(DateTime date) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final response = await dio.get(
        '/nutrition/meals',
        queryParameters: {'date': dateString},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => MealModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lấy bữa ăn thất bại',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<MealModel> addFoodToMeal(AddMealItemRequestModel request) async {
    try {
      final response = await dio.post(
        '/nutrition/meals/item',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return MealModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Thêm món ăn thất bại',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteMealItem(int mealItemId) async {
    try {
      final response = await dio.delete('/nutrition/meals/item/$mealItemId');
      if (response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Xóa món ăn thất bại',
        );
      }
    } on DioException {
      rethrow;
    }
  }
}
