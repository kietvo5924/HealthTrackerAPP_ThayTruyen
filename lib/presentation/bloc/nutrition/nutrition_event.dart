part of 'nutrition_bloc.dart';

abstract class NutritionEvent extends Equatable {
  const NutritionEvent();

  @override
  List<Object> get props => [];
}

// Event khi người dùng chọn một ngày (để tải bữa ăn)
class NutritionGetMeals extends NutritionEvent {
  final DateTime date;
  const NutritionGetMeals(this.date);

  @override
  List<Object> get props => [date];
}

// Event khi người dùng tìm kiếm thức ăn
class NutritionSearchFood extends NutritionEvent {
  final String query;
  const NutritionSearchFood(this.query);

  @override
  List<Object> get props => [query];
}

// Event khi người dùng thêm một món ăn
class NutritionAddFood extends NutritionEvent {
  final AddFoodParams params;
  const NutritionAddFood(this.params);

  @override
  List<Object> get props => [params];
}

// Event khi người dùng xóa một món ăn
class NutritionDeleteFood extends NutritionEvent {
  final int mealItemId;
  const NutritionDeleteFood(this.mealItemId);

  @override
  List<Object> get props => [mealItemId];
}
