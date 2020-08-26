import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
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
  Future<Either<Failure, String>> getJWT(
      String emailAddress, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final jwt = await remoteDataSource.getJWT(emailAddress, password);
        // localDataSource.cacheUser(remoteUser);
        return Right(jwt);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signIn(String jwt) async {
    return await _requestUserAction(() {
      return remoteDataSource.signIn(jwt);
    });
  }

  @override
  Future<Either<Failure, String>> register(
      String emailAddress, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final jwt = await remoteDataSource.register(emailAddress, password);
        // localDataSource.cacheUser(remoteUser);
        return Right(jwt);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updatePassword(
      String emailAddress, String newPassword) async {
    return await _requestUserAction(() {
      return remoteDataSource.updatePassword(emailAddress, newPassword);
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
