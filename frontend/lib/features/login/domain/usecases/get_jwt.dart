import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_repository.dart';
import 'sign_in.dart';

class GetJWT implements UseCase<String, LoginParams> {
  final UserRepository repository;

  GetJWT(this.repository);

  @override
  Future<Either<Failure, String>> call(LoginParams loginParams) async {
    return await repository.getJWT(
      loginParams.emailAddress,
      loginParams.password,
    );
  }
}
