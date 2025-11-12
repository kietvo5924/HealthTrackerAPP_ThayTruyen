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
  void initState() {
    super.initState();
    context.read<NutritionBloc>().add(const NutritionSearchFood(''));
  }

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
            // Thêm padding cho danh sách
            padding: const EdgeInsets.only(bottom: 96), // Để không bị FAB che
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final food = state.searchResults[index];
              // Sử dụng widget mới
              return FoodSearchResultTile(
                food: food,
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

// --- THÊM CÁC WIDGET NÀY VÀO CUỐI FILE search_food_page.dart ---

/// Widget mới để hiển thị kết quả tìm kiếm món ăn đẹp hơn
class FoodSearchResultTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;

  const FoodSearchResultTile({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng 1: Tên và Đơn vị
              Text(
                food.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'trên 1 ${food.unit}', // Hiển thị đơn vị
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Hàng 2: 4 thông số
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MacroTile(
                    label: 'Calo',
                    value: food.calories,
                    unit: 'kcal',
                    color: Colors.orange,
                  ),
                  _MacroTile(
                    label: 'Đạm',
                    value: food.proteinGrams,
                    unit: 'g',
                    color: Colors.blue.shade600,
                  ),
                  _MacroTile(
                    label: 'Carb',
                    value: food.carbsGrams,
                    unit: 'g',
                    color: Colors.green.shade600,
                  ),
                  _MacroTile(
                    label: 'Béo',
                    value: food.fatGrams,
                    unit: 'g',
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget con (helper) để hiển thị 1 thông số
class _MacroTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Quyết định format (số nguyên cho Calo, 1 số lẻ cho macros)
    final String valueString = (label == 'Calo')
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$valueString $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
