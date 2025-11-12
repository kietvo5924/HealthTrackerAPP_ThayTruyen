import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/usecases/create_food_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/nutrition/nutrition_bloc.dart';

class CreateFoodPage extends StatefulWidget {
  const CreateFoodPage({super.key});

  @override
  State<CreateFoodPage> createState() => _CreateFoodPageState();
}

class _CreateFoodPageState extends State<CreateFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: '100g'); // Đặt mặc định
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  // Hàm Submit Form
  void _submitForm() {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // Kiểm tra Form
    if (_formKey.currentState?.validate() ?? false) {
      final params = CreateFoodParams(
        name: _nameController.text,
        unit: _unitController.text,
        calories: double.parse(_caloriesController.text),
        proteinGrams: double.parse(_proteinController.text),
        carbsGrams: double.parse(_carbsController.text),
        fatGrams: double.parse(_fatController.text),
      );
      // Gọi BLoC
      context.read<NutritionBloc>().add(NutritionCreateFood(params));
    }
  }

  // Hàm helper để kiểm tra số (calo, protein...)
  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được rỗng';
    }
    if (double.tryParse(value) == null) {
      return 'Vui lòng nhập số hợp lệ';
    }
    if (double.parse(value) < 0) {
      return '$fieldName không được âm';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo món ăn mới')),
      body: BlocListener<NutritionBloc, NutritionState>(
        listener: (context, state) {
          // Lắng nghe khi tạo thành công
          if (state.createFoodStatus == FoodCreateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tạo món ăn thành công!')),
            );
            Navigator.of(context).pop(); // Đóng trang này
          }
          // Lắng nghe khi tạo thất bại
          if (state.createFoodStatus == FoodCreateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.createFoodErrorMessage}')),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên món ăn*',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên không được rỗng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Đơn vị*',
                    hintText: 'ví dụ: 100g, 1 dĩa, 1 chén',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Đơn vị không được rỗng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calo (kcal)*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => _validateNumber(v, 'Calo'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _proteinController,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => _validateNumber(v, 'Protein'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Carb (g)*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => _validateNumber(v, 'Carb'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fatController,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => _validateNumber(v, 'Fat'),
                ),
                const SizedBox(height: 32),
                BlocBuilder<NutritionBloc, NutritionState>(
                  builder: (context, state) {
                    return state.createFoodStatus == FoodCreateStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Lưu món ăn'),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
