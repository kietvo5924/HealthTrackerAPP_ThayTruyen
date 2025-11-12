import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/domain/entities/food.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';
import 'package:health_tracker_app/domain/usecases/add_food_to_meal_usecase.dart';
import 'package:health_tracker_app/domain/usecases/create_food_usecase.dart';
import 'package:health_tracker_app/domain/usecases/delete_meal_item_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_meals_for_date_usecase.dart';
import 'package:health_tracker_app/domain/usecases/search_food_usecase.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // Để dùng debounce

part 'nutrition_event.dart';
part 'nutrition_state.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final GetMealsForDateUseCase _getMealsForDateUseCase;
  final SearchFoodUseCase _searchFoodUseCase;
  final AddFoodToMealUseCase _addFoodToMealUseCase;
  final DeleteMealItemUseCase _deleteMealItemUseCase;
  final CreateFoodUseCase _createFoodUseCase;

  NutritionBloc({
    required GetMealsForDateUseCase getMealsForDateUseCase,
    required SearchFoodUseCase searchFoodUseCase,
    required AddFoodToMealUseCase addFoodToMealUseCase,
    required DeleteMealItemUseCase deleteMealItemUseCase,
    required CreateFoodUseCase createFoodUseCase,
  }) : _getMealsForDateUseCase = getMealsForDateUseCase,
       _searchFoodUseCase = searchFoodUseCase,
       _addFoodToMealUseCase = addFoodToMealUseCase,
       _deleteMealItemUseCase = deleteMealItemUseCase,
       _createFoodUseCase = createFoodUseCase,
       super(NutritionState.initial()) {
    on<NutritionGetMeals>(_onGetMeals);
    on<NutritionSearchFood>(
      _onSearchFood,
      // Thêm debounce: chỉ tìm kiếm sau khi người dùng ngừng gõ 500ms
      transformer: restartable(),
    );
    on<NutritionAddFood>(_onAddFood);
    on<NutritionDeleteFood>(_onDeleteFood);
    on<NutritionCreateFood>(_onCreateFood);
  }

  Future<void> _onGetMeals(
    NutritionGetMeals event,
    Emitter<NutritionState> emit,
  ) async {
    emit(
      state.copyWith(status: NutritionStatus.loading, selectedDate: event.date),
    );

    final result = await _getMealsForDateUseCase(event.date);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: NutritionStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (meals) {
        emit(state.copyWith(status: NutritionStatus.success, meals: meals));
      },
    );
  }

  Future<void> _onSearchFood(
    NutritionSearchFood event,
    Emitter<NutritionState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(
        state.copyWith(
          searchStatus: FoodSearchStatus.initial,
          searchResults: [],
        ),
      );
      return;
    }

    emit(state.copyWith(searchStatus: FoodSearchStatus.loading));

    final result = await _searchFoodUseCase(event.query);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            searchStatus: FoodSearchStatus.failure,
            searchErrorMessage: failure.message,
          ),
        );
      },
      (foods) {
        emit(
          state.copyWith(
            searchStatus: FoodSearchStatus.success,
            searchResults: foods,
          ),
        );
      },
    );
  }

  Future<void> _onAddFood(
    NutritionAddFood event,
    Emitter<NutritionState> emit,
  ) async {
    // Đặt trạng thái loading (nhưng giữ data cũ)
    emit(state.copyWith(status: NutritionStatus.loading, clearError: true));

    final result = await _addFoodToMealUseCase(event.params);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: NutritionStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedMeal) {
        // Thêm/cập nhật bữa ăn thành công, tải lại toàn bộ
        add(NutritionGetMeals(state.selectedDate));
      },
    );
  }

  Future<void> _onDeleteFood(
    NutritionDeleteFood event,
    Emitter<NutritionState> emit,
  ) async {
    emit(state.copyWith(status: NutritionStatus.loading, clearError: true));

    final result = await _deleteMealItemUseCase(event.mealItemId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: NutritionStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (success) {
        // Xóa thành công, tải lại toàn bộ
        add(NutritionGetMeals(state.selectedDate));
      },
    );
  }

  Future<void> _onCreateFood(
    NutritionCreateFood event,
    Emitter<NutritionState> emit,
  ) async {
    emit(
      state.copyWith(
        createFoodStatus: FoodCreateStatus.loading,
        clearError: true,
      ),
    );

    final result = await _createFoodUseCase(event.params);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            createFoodStatus: FoodCreateStatus.failure,
            createFoodErrorMessage: failure.message,
          ),
        );
      },
      (newFood) {
        emit(state.copyWith(createFoodStatus: FoodCreateStatus.success));
      },
    );
  }
}
