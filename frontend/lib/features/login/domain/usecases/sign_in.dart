import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SignIn implements UseCase<User, String> {
  final UserRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(String jwt) async {
    return await repository.signIn(jwt);
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
