import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

typedef Future<User> _RequestUserActionChooser();

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signIn(
      String emailAddress, String password) async {
    return await _requestUserAction(() {
      return remoteDataSource.signIn(emailAddress, password);
    });
  }

  @override
  Future<Either<Failure, User>> register(
      String emailAddress, String password) async {
    return await _requestUserAction(() {
      return remoteDataSource.register(emailAddress, password);
    });
  }

  @override
  Future<Either<Failure, User>> configureWifi(WifiParams params) async {
    return await _requestUserAction(() {
      return remoteDataSource.configureWifi(params);
    });
  }

  @override
  Future<Either<Failure, User>> updatePassword(NoParams params) async {
    return await _requestUserAction(() {
      return remoteDataSource.updatePassword(NoParams());
    });
  }

  Future<Either<Failure, User>> _requestUserAction(
    _RequestUserActionChooser requestUserAction,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await requestUserAction();
        localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendVerificationCode(
      String emailAddress) async {
    if (await networkInfo.isConnected) {
      try {
        final verficiationCode =
            await remoteDataSource.sendVerificationCode(emailAddress);
        return Right(verficiationCode);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
