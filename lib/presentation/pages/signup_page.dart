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

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

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
            _SignupButton(),
          ],
        ),
      ),
    );
  }
}

class _FullNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (p, c) => p.fullName != c.fullName,
      builder: (context, state) {
        return TextField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupFullNameChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Họ và tên',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.name,
        );
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
        return TextField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupPhoneNumberChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        );
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
        return TextField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupEmailChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        );
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
        return TextField(
          onChanged: (value) {
            context.read<SignupBloc>().add(SignupPasswordChanged(value));
          },
          decoration: const InputDecoration(
            labelText: 'Mật khẩu',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        );
      },
    );
  }
}

class _SignupButton extends StatelessWidget {
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
                onPressed: () {
                  context.read<SignupBloc>().add(SignupSubmitted());
                },
                child: const Text('ĐĂNG KÝ'),
              );
      },
    );
  }
}
