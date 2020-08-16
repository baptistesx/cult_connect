import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> signIn(String emailAddress, String password);
  Future<Either<Failure, User>> register(String emailAddress, String password);
  Future<Either<Failure, User>> updatePassword(
      String emailAddress, String password);
  Future<Either<Failure, String>> sendVerificationCode(String emailAddress);
}
