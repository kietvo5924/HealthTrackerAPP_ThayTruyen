// Tương ứng với AddMealItemRequestDTO.java
class AddMealItemRequestModel {
  final int foodId;
  final String date; // YYYY-MM-DD
  final String mealType; // "BREAKFAST", "LUNCH", ...
  final double quantity;

  AddMealItemRequestModel({
    required this.foodId,
    required this.date,
    required this.mealType,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'date': date,
      'mealType': mealType,
      'quantity': quantity,
    };
  }
}
