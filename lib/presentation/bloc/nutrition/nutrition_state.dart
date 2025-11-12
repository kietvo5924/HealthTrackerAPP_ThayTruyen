part of 'nutrition_bloc.dart';

enum NutritionStatus { initial, loading, success, failure }

enum FoodSearchStatus { initial, loading, success, failure }

enum FoodCreateStatus { initial, loading, success, failure }

class NutritionState extends Equatable {
  // Trạng thái chung (tải bữa ăn, thêm/xóa)
  final NutritionStatus status;
  final List<Meal> meals; // Danh sách bữa ăn (Sáng, Trưa, Tối, Phụ)
  final String? errorMessage;
  final DateTime selectedDate; // Ngày đang xem

  // Trạng thái tìm kiếm (cho thanh search)
  final FoodSearchStatus searchStatus;
  final List<Food> searchResults;
  final String? searchErrorMessage;

  final FoodCreateStatus createFoodStatus;
  final String? createFoodErrorMessage;

  const NutritionState({
    this.status = NutritionStatus.initial,
    this.meals = const [],
    this.errorMessage,
    required this.selectedDate,
    this.searchStatus = FoodSearchStatus.initial,
    this.searchResults = const [],
    this.searchErrorMessage,
    this.createFoodStatus = FoodCreateStatus.initial,
    this.createFoodErrorMessage,
  });

  // Constructor khởi tạo
  factory NutritionState.initial() {
    final now = DateTime.now();
    return NutritionState(selectedDate: DateTime(now.year, now.month, now.day));
  }

  NutritionState copyWith({
    NutritionStatus? status,
    List<Meal>? meals,
    String? errorMessage,
    DateTime? selectedDate,
    FoodSearchStatus? searchStatus,
    List<Food>? searchResults,
    String? searchErrorMessage,
    bool clearError = false,
    FoodCreateStatus? createFoodStatus,
    String? createFoodErrorMessage,
  }) {
    return NutritionState(
      status: status ?? this.status,
      meals: meals ?? this.meals,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      searchErrorMessage: clearError
          ? null
          : searchErrorMessage ?? this.searchErrorMessage,
      createFoodStatus: createFoodStatus ?? this.createFoodStatus,
      createFoodErrorMessage: clearError
          ? null
          : createFoodErrorMessage ?? this.createFoodErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    meals,
    errorMessage,
    selectedDate,
    searchStatus,
    searchResults,
    searchErrorMessage,
    createFoodStatus,
    createFoodErrorMessage,
  ];
}
