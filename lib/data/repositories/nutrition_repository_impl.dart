import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/nutrition_remote_data_source.dart';
import 'package:health_tracker_app/data/models/add_meal_item_request_model.dart';
import 'package:health_tracker_app/domain/entities/food.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';
import 'package:intl/intl.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionRemoteDataSource remoteDataSource;

  NutritionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Food>>> searchFood(String query) async {
    try {
      final foodList = await remoteDataSource.searchFood(query);
      return Right(foodList);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsForDate(DateTime date) async {
    try {
      final mealList = await remoteDataSource.getMealsForDate(date);
      return Right(mealList);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meal>> addFoodToMeal({
    required int foodId,
    required DateTime date,
    required MealType mealType,
    required double quantity,
  }) async {
    try {
      // 1. Chuyển đổi dữ liệu sang Request DTO
      final requestModel = AddMealItemRequestModel(
        foodId: foodId,
        date: DateFormat('yyyy-MM-dd').format(date),
        mealType: mealType
            .toString()
            .split('.')
            .last, // "MealType.BREAKFAST" -> "BREAKFAST"
        quantity: quantity,
      );

      // 2. Gọi API
      final updatedMeal = await remoteDataSource.addFoodToMeal(requestModel);
      return Right(updatedMeal);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMealItem(int mealItemId) async {
    try {
      await remoteDataSource.deleteMealItem(mealItemId);
      return const Right(null); // Trả về Right(null) khi thành công
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
