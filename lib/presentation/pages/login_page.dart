import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/core/di/service_locator.dart';
import 'package:health_tracker_app/presentation/bloc/login/login_bloc.dart';
import 'package:health_tracker_app/presentation/pages/signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      // Cung cấp LoginBloc cho trang này
      body: BlocProvider(
        create: (context) => sl<LoginBloc>(),
        child: const LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      // Lắng nghe các thay đổi state một lần (show dialog, snackbar)
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
        }
        // state.isSuccess đã được xử lý bởi AuthBloc,
        // AuthBloc sẽ tự động điều hướng sang HomePage
      },
      // Xây dựng UI dựa trên state
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EmailInput(),
            const SizedBox(height: 16),
            _PasswordInput(),
            const SizedBox(height: 32),
            _LoginButton(),
            const SizedBox(height: 16),
            _SignupButton(),
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (p, c) => p.email != c.email,
      builder: (context, state) {
        return TextField(
          onChanged: (email) {
            context.read<LoginBloc>().add(LoginEmailChanged(email));
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
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (p, c) => p.password != c.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) {
            context.read<LoginBloc>().add(LoginPasswordChanged(password));
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

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (p, c) => p.isLoading != c.isLoading,
      builder: (context, state) {
        return state.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  context.read<LoginBloc>().add(LoginSubmitted());
                },
                child: const Text('ĐĂNG NHẬP'),
              );
      },
    );
  }
}

class _SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SignupPage()));
      },
      child: const Text('Chưa có tài khoản? Đăng ký ngay'),
    );
  }
}
