import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/auth_repository.dart';

class GetAuthTokenUseCase implements UseCase<String?, NoParams> {
  final AuthRepository authRepository;

  GetAuthTokenUseCase(this.authRepository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await authRepository.getAuthToken();
  }
}
