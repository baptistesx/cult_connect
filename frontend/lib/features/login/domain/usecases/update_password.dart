import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import 'sign_in.dart';

class UpdatePassword implements UseCase<String, LoginParams> {
  final UserRepository repository;

  UpdatePassword(this.repository);

  @override
  Future<Either<Failure, String>> call(LoginParams loginParams) async {
    return await repository.updatePassword(
        loginParams.emailAddress, loginParams.password);
  }
}
