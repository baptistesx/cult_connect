import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import 'sign_in.dart';

class Register implements UseCase<User, LoginParams> {
  final UserRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams loginParams) async {
    return await repository.register(
      loginParams.emailAddress,
      loginParams.password,
    );
  }
}
