import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../login/domain/entities/user.dart';
import '../../domain/entities/module.dart';
import '../../domain/repositories/modules_repository.dart';
import '../../domain/usecases/add_module.dart';
import '../datasources/modules_remote_data_source.dart';

class ModulesRepositoryImpl implements ModulesRepository {
  final ModulesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ModulesRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Module>>> getModules(String token) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModules = await remoteDataSource.getModules(token);
        return Right(remoteModules);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, User>> addModule(AddModuleParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.addModule(params);
        return Right(remoteUser);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
