import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi chung từ Server (API)
class ServerFailure extends Failure {
  // ignore: use_super_parameters
  const ServerFailure(String message) : super(message);
}

// Lỗi khi không có kết nối mạng
class NetworkFailure extends Failure {
  // ignore: use_super_parameters
  const NetworkFailure(String message) : super(message);
}

// Lỗi từ Local Storage (SharedPreferences)
class CacheFailure extends Failure {
  // ignore: use_super_parameters
  const CacheFailure(String message) : super(message);
}

// Lỗi chung khác
class GenericFailure extends Failure {
  // ignore: use_super_parameters
  const GenericFailure(String message) : super(message);
}
