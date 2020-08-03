import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../usecases/configure_wifi.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> signIn(String emailAddress, String password);
  Future<Either<Failure, User>> register(String emailAddress, String password);
  Future<Either<Failure, User>> configureWifi(WifiParams params);
  Future<Either<Failure, User>> updatePassword(NoParams params);
  Future<Either<Failure, String>> sendVerificationCode(String emailAddress);
}
