import 'package:health_tracker_app/data/models/meal_item_model.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.mealType,
    required List<MealItemModel> items, // Yêu cầu kiểu MealItemModel
    required super.totalMealCalories,
  }) : super(items: items); // Truyền lên constructor của lớp cha

  factory MealModel.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi List<dynamic> (từ JSON) thành List<MealItemModel>
    final itemsList = (json['items'] as List)
        .map((itemJson) => MealItemModel.fromJson(itemJson))
        .toList();

    return MealModel(
      id: json['id'],
      mealType: _mealTypeFromString(json['mealType']),
      items: itemsList,
      totalMealCalories: json['totalMealCalories']?.toDouble() ?? 0.0,
    );
  }

  // Hàm helper để chuyển String (từ JSON) thành Enum
  static MealType _mealTypeFromString(String type) {
    switch (type) {
      case 'BREAKFAST':
        return MealType.BREAKFAST;
      case 'LUNCH':
        return MealType.LUNCH;
      case 'DINNER':
        return MealType.DINNER;
      case 'SNACK':
        return MealType.SNACK;
      default:
        // Mặc định là SNACK nếu có lỗi
        return MealType.SNACK;
    }
  }
}
