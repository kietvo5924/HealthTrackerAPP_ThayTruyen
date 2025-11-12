import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/entities/food.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';
import 'package:health_tracker_app/domain/usecases/add_food_to_meal_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/nutrition/nutrition_bloc.dart';

// --- THÊM IMPORT MỚI ---
import 'package:health_tracker_app/presentation/pages/create_food_page.dart';
// --- KẾT THÚC THÊM MỚI ---

class SearchFoodPage extends StatefulWidget {
  final MealType mealType;
  final DateTime selectedDate;

  const SearchFoodPage({
    super.key,
    required this.mealType,
    required this.selectedDate,
  });

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm hiển thị dialog nhập số lượng
  void _showAddFoodDialog(BuildContext context, Food food) {
    final quantityController = TextEditingController(text: '1.0');
    final bloc = context.read<NutritionBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Thêm ${food.name}'),
          content: TextFormField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Số lượng (${food.unit})',
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? quantity = double.tryParse(
                  quantityController.text,
                );
                if (quantity != null && quantity > 0) {
                  // Tạo params
                  final params = AddFoodParams(
                    foodId: food.id,
                    date: widget.selectedDate,
                    mealType: widget.mealType,
                    quantity: quantity,
                  );
                  // Add event
                  bloc.add(NutritionAddFood(params));

                  Navigator.of(dialogContext).pop(); // Đóng Dialog
                  Navigator.of(context).pop(); // Đóng trang Search
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm vào ${widget.mealType.toString().split('.').last.toLowerCase()}',
        ),
        // Thanh Search
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm thực phẩm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                // BLoC đã có debounce (trì hoãn)
                context.read<NutritionBloc>().add(NutritionSearchFood(query));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<NutritionBloc, NutritionState>(
        builder: (context, state) {
          // Trạng thái tìm kiếm
          if (state.searchStatus == FoodSearchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.searchStatus == FoodSearchStatus.failure) {
            return Center(child: Text('Lỗi: ${state.searchErrorMessage}'));
          }
          if (state.searchStatus == FoodSearchStatus.success &&
              state.searchResults.isEmpty) {
            return const Center(child: Text('Không tìm thấy kết quả nào.'));
          }

          // Hiển thị kết quả
          return ListView.builder(
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final food = state.searchResults[index];
              return ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '${food.calories.toInt()} kcal / 1 ${food.unit}',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  _showAddFoodDialog(context, food);
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                // Chuyền BLoC (đã có) sang trang mới
                value: context.read<NutritionBloc>(),
                child: const CreateFoodPage(),
              ),
            ),
          );
        },
        label: const Text('Tạo món ăn'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
