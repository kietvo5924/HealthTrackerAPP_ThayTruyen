import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';
import 'package:health_tracker_app/domain/entities/meal_item.dart';
import 'package:health_tracker_app/presentation/bloc/nutrition/nutrition_bloc.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_app/presentation/pages/search_food_page.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  // Hàm helper để tìm bữa ăn theo loại
  Meal? _findMeal(List<Meal> meals, MealType type) {
    try {
      return meals.firstWhere((meal) => meal.mealType == type);
    } catch (e) {
      return null; // Không tìm thấy
    }
  }

  // Hàm helper để tính tổng calo
  double _calculateTotalCalories(List<Meal> meals) {
    return meals.fold(0.0, (sum, meal) => sum + meal.totalMealCalories);
  }

  // --- THÊM HÀM MỚI ---
  // Hàm điều hướng đến trang tìm kiếm
  void _navigateSearchFood(
    BuildContext context,
    MealType mealType,
    DateTime selectedDate,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          // Chuyền BLoC (đã có) sang trang mới
          value: context.read<NutritionBloc>(),
          child: SearchFoodPage(mealType: mealType, selectedDate: selectedDate),
        ),
      ),
    );
  }
  // --- KẾT THÚC THÊM MỚI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Dinh dưỡng'),
        actions: [
          // Nút chọn ngày
          BlocBuilder<NutritionBloc, NutritionState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: state.selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != state.selectedDate) {
                    context.read<NutritionBloc>().add(
                      NutritionGetMeals(pickedDate),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NutritionBloc, NutritionState>(
        builder: (context, state) {
          if (state.status == NutritionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == NutritionStatus.failure) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          // Tách danh sách bữa ăn
          final breakfast = _findMeal(state.meals, MealType.BREAKFAST);
          final lunch = _findMeal(state.meals, MealType.LUNCH);
          final dinner = _findMeal(state.meals, MealType.DINNER);
          final snack = _findMeal(state.meals, MealType.SNACK);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Tiêu đề (Ngày và Tổng Calo)
                _buildHeader(
                  context,
                  state.selectedDate,
                  _calculateTotalCalories(state.meals),
                ),
                const SizedBox(height: 24),

                // 2. Danh sách 4 bữa ăn (CẬP NHẬT onAdd)
                _MealCard(
                  title: 'Bữa sáng',
                  meal: breakfast,
                  onAdd: () => _navigateSearchFood(
                    context,
                    MealType.BREAKFAST,
                    state.selectedDate,
                  ),
                ),
                _MealCard(
                  title: 'Bữa trưa',
                  meal: lunch,
                  onAdd: () => _navigateSearchFood(
                    context,
                    MealType.LUNCH,
                    state.selectedDate,
                  ),
                ),
                _MealCard(
                  title: 'Bữa tối',
                  meal: dinner,
                  onAdd: () => _navigateSearchFood(
                    context,
                    MealType.DINNER,
                    state.selectedDate,
                  ),
                ),
                _MealCard(
                  title: 'Bữa phụ',
                  meal: snack,
                  onAdd: () => _navigateSearchFood(
                    context,
                    MealType.SNACK,
                    state.selectedDate,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget header
  Widget _buildHeader(
    BuildContext context,
    DateTime date,
    double totalCalories,
  ) {
    return Column(
      children: [
        Text(
          DateFormat.yMMMMEEEEd('vi_VN').format(date),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '${totalCalories.toInt()} kcal',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

// Widget cho một thẻ Bữa ăn (Sáng/Trưa/Tối/Phụ)
class _MealCard extends StatelessWidget {
  final String title;
  final Meal? meal;
  final VoidCallback onAdd;

  const _MealCard({required this.title, this.meal, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề (VD: Bữa sáng - 350 kcal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '${meal?.totalMealCalories.toInt() ?? 0} kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Danh sách các món ăn
            if (meal == null || meal!.items.isEmpty)
              const Text(
                'Chưa có món ăn nào',
                style: TextStyle(color: Colors.grey),
              )
            else
              _buildMealItemsList(meal!.items),

            // Nút Thêm
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Thêm món ăn'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị danh sách các món ăn đã thêm
  Widget _buildMealItemsList(List<MealItem> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.foodName),
          subtitle: Text(
            '${item.quantity.toString()} ${item.unit} - ${item.totalCalories.toInt()} kcal',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              // Gọi BLoC để xóa
              context.read<NutritionBloc>().add(NutritionDeleteFood(item.id));
            },
          ),
        );
      },
    );
  }
}
