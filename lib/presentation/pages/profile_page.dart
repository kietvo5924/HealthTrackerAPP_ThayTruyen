import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/profile/profile_bloc.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(ProfileFetched()),
      child: Scaffold(
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
