import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/log_workout_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:intl/intl.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Biến cho state của Form
  WorkoutType? _selectedType = WorkoutType.RUNNING;
  DateTime _selectedDateTime = DateTime.now();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  // Hàm chọn ngày
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return; // Người dùng hủy

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return; // Người dùng hủy

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // Hàm Submit
  void _submitForm() {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // Validate
    if (_formKey.currentState?.validate() ?? false) {
      final params = LogWorkoutParams(
        workoutType: _selectedType!,
        durationInMinutes: int.parse(_durationController.text),
        startedAt: _selectedDateTime.toUtc(), // Gửi lên server dạng UTC
        caloriesBurned: double.tryParse(_caloriesController.text),
      );

      // Thêm event vào BLoC
      context.read<WorkoutBloc>().add(WorkoutAdded(params));
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm bài tập')),
      body: BlocListener<WorkoutBloc, WorkoutState>(
        listener: (context, state) {
          // Lắng nghe khi gửi thành công
          if (!state.isSubmitting && state.submissionError == null) {
            // Đóng trang này và quay về
            Navigator.of(context).pop();
          }
          // Lắng nghe khi gửi thất bại
          if (state.submissionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.submissionError}')),
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
                // 1. Chọn loại bài tập
                DropdownButtonFormField<WorkoutType>(
                  // ignore: deprecated_member_use
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Loại bài tập',
                    border: OutlineInputBorder(),
                  ),
                  items: WorkoutType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 2. Chọn ngày giờ
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Thời gian bắt đầu',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  // Hiển thị ngày giờ đã chọn
                  controller: TextEditingController(
                    text: DateFormat.yMd().add_Hm().format(
                      _selectedDateTime.toLocal(),
                    ),
                  ),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 16),

                // 3. Nhập thời lượng
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Thời lượng (phút)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập thời lượng';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Vui lòng nhập số phút hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. Nhập Calo
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calo đã đốt (kcal - tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // 5. Nút Lưu
                BlocBuilder<WorkoutBloc, WorkoutState>(
                  builder: (context, state) {
                    return state.isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Lưu bài tập'),
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

// (Chúng ta đã có extension này ở workout_page.dart,
// nhưng để ở đây để file này chạy độc lập nếu cần)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
