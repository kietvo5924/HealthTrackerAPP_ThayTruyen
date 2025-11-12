import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/signup/signup_bloc.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: BlocProvider(
        create: (context) => sl<SignupBloc>(),
        child: const SignupForm(),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

// --- CHUYỂN SANG STATEFULWIDGET ĐỂ DÙNG FORMENT ---
class _SignupFormState extends State<SignupForm> {
  // --- THÊM MỚI ---
  final _formKey = GlobalKey<FormState>();
  // --- KẾT THÚC THÊM MỚI ---

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.status == SignupStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Lỗi: ${state.message}')));
        }
        if (state.status == SignupStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
          // Quay lại trang Đăng nhập sau khi thành công
          Navigator.of(context).pop();
        }
      },
      // --- THÊM MỚI (Bọc bằng Form) ---
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _FullNameInput(),
              const SizedBox(height: 16),
              _PhoneNumberInput(),
              const SizedBox(height: 16),
              _EmailInput(),
              const SizedBox(height: 16),
              _PasswordInput(),
              const SizedBox(height: 32),
              // Truyền _formKey vào nút bấm
              _SignupButton(formKey: _formKey),
            ],
          ),
        ),
      ),
      // --- KẾT THÚC THÊM MỚI ---
    );
  }
}

class _FullNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (p, c) => p.fullName != c.fullName,
      builder: (context, state) {
        // --- SỬA ĐỔI (Thêm TextFormField và validator) ---
        return TextFormField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupFullNameChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Họ và tên',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Họ tên không được để trống';
            }
            return null;
          },
        );
        // --- KẾT THÚC SỬA ĐỔI ---
      },
    );
  }
}

class _PhoneNumberInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (p, c) => p.phoneNumber != c.phoneNumber,
      builder: (context, state) {
        // --- SỬA ĐỔI (Thêm TextFormField và validator) ---
        return TextFormField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupPhoneNumberChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Số điện thoại không được để trống';
            }
            if (value.length != 10) {
              return 'Số điện thoại phải có đúng 10 chữ số';
            }
            return null;
          },
        );
        // --- KẾT THÚC SỬA ĐỔI ---
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (p, c) => p.email != c.email,
      builder: (context, state) {
        // --- SỬA ĐỔI (Thêm TextFormField và validator) ---
        return TextFormField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupEmailChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email không được để trống';
            }
            // Biểu thức chính quy (RegExp) đơn giản để kiểm tra email
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(value)) {
              return 'Email không đúng định dạng';
            }
            return null;
          },
        );
        // --- KẾT THÚC SỬA ĐỔI ---
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (p, c) => p.password != c.password,
      builder: (context, state) {
        // --- SỬA ĐỔI (Thêm TextFormField và validator) ---
        return TextFormField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupPasswordChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Mật khẩu',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mật khẩu không được để trống';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        );
        // --- KẾT THÚC SỬA ĐỔI ---
      },
    );
  }
}

class _SignupButton extends StatelessWidget {
  // --- THÊM MỚI ---
  final GlobalKey<FormState> formKey;
  const _SignupButton({required this.formKey});
  // --- KẾT THÚC THÊM MỚI ---

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        return state.status == SignupStatus.loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                // --- CẬP NHẬT onPressed ---
                onPressed: () {
                  // Kiểm tra xem form có hợp lệ không
                  if (formKey.currentState?.validate() ?? false) {
                    // Nếu hợp lệ, submit
                    context.read<SignupBloc>().add(SignupSubmitted());
                  } else {
                    // Nếu không hợp lệ, hiển thị SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng kiểm tra lại thông tin'),
                      ),
                    );
                  }
                },
                // --- KẾT THÚC CẬP NHẬT ---
                child: const Text('ĐĂNG KÝ'),
              );
      },
    );
  }
}
