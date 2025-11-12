import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/food.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';

// Usecase để tạo món ăn mới
// Input: CreateFoodParams, Output: Food (món ăn vừa tạo)
class CreateFoodUseCase implements UseCase<Food, CreateFoodParams> {
  final NutritionRepository nutritionRepository;

  CreateFoodUseCase(this.nutritionRepository);

  @override
  Future<Either<Failure, Food>> call(CreateFoodParams params) async {
    return await nutritionRepository.createFood(
      name: params.name,
      unit: params.unit,
      calories: params.calories,
      proteinGrams: params.proteinGrams,
      carbsGrams: params.carbsGrams,
      fatGrams: params.fatGrams,
    );
  }
}

// Class chứa các tham số cho Usecase
class CreateFoodParams extends Equatable {
  final String name;
  final String unit;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  const CreateFoodParams({
    required this.name,
    required this.unit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  @override
  List<Object?> get props => [
    name,
    unit,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
  ];
}
