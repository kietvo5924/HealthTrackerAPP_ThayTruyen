import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          _SaveProfileButton(), // Nút lưu
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
              );
          } else if (state.status == ProfileStatus.success &&
              // ignore: prefer_is_not_empty
              !state.userProfile!.fullName.isEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Cập nhật thành công!')),
              );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.userProfile == null) {
            return const Center(child: Text('Không tải được hồ sơ.'));
          }
          // Khi đã có dữ liệu
          return const ProfileForm();
        },
      ),
    );
  }
}

class _SaveProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileStatus.updating) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }
        return IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            context.read<ProfileBloc>().add(ProfileSubmitted());
          },
        );
      },
    );
  }
}

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Key để khởi tạo giá trị cho các TextFormField
    final profile = context.select(
      (ProfileBloc bloc) => bloc.state.userProfile!,
    );
    final goalStepsController = TextEditingController(
      text: profile.goalSteps.toString(),
    );
    final goalWaterController = TextEditingController(
      text: profile.goalWater.toString(),
    );
    final goalSleepController = TextEditingController(
      text: profile.goalSleep.toString(),
    );
    final goalCaloriesBurntController = TextEditingController(
      text: profile.goalCaloriesBurnt.toString(),
    );
    final goalCaloriesConsumedController = TextEditingController(
      text: profile.goalCaloriesConsumed.toString(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: profile.email,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            enabled: false, // Không cho sửa email
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: profile.fullName,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<ProfileBloc>().add(ProfileFullNameChanged(value));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: profile.phoneNumber,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<ProfileBloc>().add(ProfilePhoneNumberChanged(value));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: profile.address,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<ProfileBloc>().add(ProfileAddressChanged(value));
            },
          ),
          const SizedBox(height: 16),
          _DateOfBirthPicker(), // Widget chọn ngày
          const SizedBox(height: 16),

          // Thêm một đường kẻ
          const Divider(thickness: 1, height: 32),
          Text(
            'Cài đặt thông báo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dùng BlocBuilder để lấy state mới nhất
          BlocBuilder<ProfileBloc, ProfileState>(
            // Chỉ build khi userProfile thay đổi
            buildWhen: (p, c) => p.userProfile != c.userProfile,
            builder: (context, state) {
              // Đảm bảo profile không null
              if (state.userProfile == null) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  SwitchListTile(
                    title: const Text('Nhắc nhở uống nước'),
                    subtitle: const Text(
                      'Nhận thông báo lúc 12:00 trưa nếu chưa uống',
                    ),
                    value: state.userProfile!.remindWater,
                    onChanged: (newValue) {
                      // Gửi event đến BLoC
                      context.read<ProfileBloc>().add(
                        ProfileNotificationSettingsChanged(
                          remindWater: newValue,
                          remindSleep: state.userProfile!.remindSleep,
                        ),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Nhắc nhở đi ngủ'),
                    subtitle: const Text('Nhận thông báo lúc 9:00 tối'),
                    value: state.userProfile!.remindSleep,
                    onChanged: (newValue) {
                      // Gửi event đến BLoC
                      context.read<ProfileBloc>().add(
                        ProfileNotificationSettingsChanged(
                          remindWater: state.userProfile!.remindWater,
                          remindSleep: newValue,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(thickness: 1, height: 32),

          Text(
            'Mục tiêu cá nhân',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Mục tiêu Bước đi
          TextFormField(
            controller: goalStepsController,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu Bước đi',
              suffixText: 'bước',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onEditingComplete: () {
              final newValue = int.tryParse(goalStepsController.text);
              if (newValue != null && newValue != profile.goalSteps) {
                context.read<ProfileBloc>().add(
                  ProfileGoalChanged(goalSteps: newValue),
                );
              }
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 16),

          // Mục tiêu Nước uống
          TextFormField(
            controller: goalWaterController,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu Nước uống',
              suffixText: 'lít',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            onEditingComplete: () {
              final newValue = double.tryParse(goalWaterController.text);
              if (newValue != null && newValue != profile.goalWater) {
                context.read<ProfileBloc>().add(
                  ProfileGoalChanged(goalWater: newValue),
                );
              }
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 16),

          // Mục tiêu Giấc ngủ
          TextFormField(
            controller: goalSleepController,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu Giấc ngủ',
              suffixText: 'giờ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            onEditingComplete: () {
              final newValue = double.tryParse(goalSleepController.text);
              if (newValue != null && newValue != profile.goalSleep) {
                context.read<ProfileBloc>().add(
                  ProfileGoalChanged(goalSleep: newValue),
                );
              }
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 16),

          // Mục tiêu Calo tiêu thụ
          TextFormField(
            controller: goalCaloriesBurntController,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu Calo vận động',
              suffixText: 'kcal',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onEditingComplete: () {
              final newValue = int.tryParse(goalCaloriesBurntController.text);
              if (newValue != null && newValue != profile.goalCaloriesBurnt) {
                context.read<ProfileBloc>().add(
                  ProfileGoalChanged(goalCaloriesBurnt: newValue),
                );
              }
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 16),

          // Mục tiêu Calo nạp vào
          TextFormField(
            controller: goalCaloriesConsumedController,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu Calo nạp vào',
              suffixText: 'kcal',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onEditingComplete: () {
              final newValue = int.tryParse(
                goalCaloriesConsumedController.text,
              );
              if (newValue != null &&
                  newValue != profile.goalCaloriesConsumed) {
                context.read<ProfileBloc>().add(
                  ProfileGoalChanged(goalCaloriesConsumed: newValue),
                );
              }
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1, height: 32),

          TextFormField(
            initialValue: profile.medicalHistory,
            decoration: const InputDecoration(
              labelText: 'Tiền sử bệnh án',
              border: OutlineInputBorder(),
              alignLabelWithHint: true, // Cho label lên trên
            ),
            maxLines: 4, // Cho phép nhập nhiều dòng
            onChanged: (value) {
              context.read<ProfileBloc>().add(
                ProfileMedicalHistoryChanged(value),
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: profile.allergies,
            decoration: const InputDecoration(
              labelText: 'Dị ứng',
              hintText: 'Ví dụ: Dị ứng phấn hoa, hải sản...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4, // Cho phép nhập nhiều dòng
            onChanged: (value) {
              context.read<ProfileBloc>().add(ProfileAllergiesChanged(value));
            },
          ),
        ],
      ),
    );
  }
}

class _DateOfBirthPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedDate = context.select(
      (ProfileBloc bloc) => bloc.state.userProfile?.dateOfBirth,
    );

    return TextFormField(
      // Dùng key để controller tự update khi state thay đổi
      key: Key(selectedDate?.toIso8601String() ?? 'dob_picker'),
      initialValue: selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(selectedDate)
          : '',
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Ngày sinh',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (newDate != null) {
          // ignore: use_build_context_synchronously
          context.read<ProfileBloc>().add(ProfileDateOfBirthChanged(newDate));
        }
      },
    );
  }
}
