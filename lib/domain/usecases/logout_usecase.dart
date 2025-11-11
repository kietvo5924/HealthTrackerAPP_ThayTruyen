import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Chúng ta cũng nên thông báo cho AuthBloc
    return await authRepository.logout();
  }
}
