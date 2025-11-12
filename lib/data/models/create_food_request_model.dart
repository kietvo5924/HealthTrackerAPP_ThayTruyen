// Tương ứng với FoodCreateRequestDTO.java
class CreateFoodRequestModel {
  final String name;
  final String unit;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  CreateFoodRequestModel({
    required this.name,
    required this.unit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
    };
  }
}
