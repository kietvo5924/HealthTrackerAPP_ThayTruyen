import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/log_workout_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/workout/workout_bloc.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_app/presentation/bloc/health_data/health_data_bloc.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Biến cho state của Form (Giữ nguyên)
  WorkoutType? _selectedType = WorkoutType.RUNNING;
  DateTime _selectedDateTime = DateTime.now();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  // Hàm chọn ngày (Giữ nguyên)
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

  // Hàm Submit (Giữ nguyên)
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
        // === SỬA LẠI LISTENER ===
        listenWhen: (previous, current) {
          // Chỉ lắng nghe khi trạng thái 'isSubmitting' thay đổi
          return previous.isSubmitting != current.isSubmitting;
        },
        listener: (context, state) {
          // 1. Kiểm tra lỗi TRƯỚC
          if (state.submissionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.submissionError}')),
            );
          }
          // 2. Nếu không có lỗi VÀ 'isSubmitting' vừa chuyển về false -> THÀNH CÔNG
          else if (!state.isSubmitting) {
            // 2a. Lấy ngày của bài tập vừa lưu
            final savedWorkoutDate = _selectedDateTime;

            // 2b. Gọi HealthDataBloc để tải lại dữ liệu cho ngày đó
            context.read<HealthDataBloc>().add(
              HealthDataFetched(savedWorkoutDate.toLocal()),
            );

            // 2c. Đóng trang
            Navigator.of(context).pop();
          }
        },
        // === KẾT THÚC SỬA LISTENER ===
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Chọn loại bài tập (Giữ nguyên)
                DropdownButtonFormField<WorkoutType>(
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

                // 2. Chọn ngày giờ (Giữ nguyên)
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Thời gian bắt đầu',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  controller: TextEditingController(
                    text: DateFormat.yMd('vi_VN').add_Hm().format(
                      // Thêm 'vi_VN'
                      _selectedDateTime.toLocal(),
                    ),
                  ),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 16),

                // 3. Nhập thời lượng (Giữ nguyên)
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

                // 4. Nhập Calo (Giữ nguyên)
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calo đã đốt (kcal - tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // 5. Nút Lưu (Giữ nguyên)
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

// (Giữ nguyên)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
