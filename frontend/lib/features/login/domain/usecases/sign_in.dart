import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SignIn implements UseCase<User, LoginParams> {
  final UserRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams loginParams) async {
    return await repository.signIn(
      loginParams.emailAddress,
      loginParams.password,
    );
  }
}

class LoginParams extends Equatable {
  String emailAddress;
  String password;

  LoginParams({
    @required this.emailAddress,
    @required this.password,
  }) : super([
          emailAddress,
          password,
        ]);
}
