import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../login/domain/entities/user.dart';
import '../../domain/entities/module.dart';
import '../../domain/repositories/modules_repository.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../../presentation/pages/dashboard_first_page.dart';
import '../../presentation/pages/sensor_datails_page.dart';
import '../datasources/modules_remote_data_source.dart';

typedef Future<User> _RequestUserActionChooser();

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
    return await _requestUserAction(() {
      return remoteDataSource.addModule(params);
    });
  }

  @override
  Future<Either<Failure, User>> removeFavouriteSensorById(
      String sensorId) async {
    return await _requestUserAction(() {
      return remoteDataSource.removeFavouriteSensorById(sensorId);
    });
  }

  @override
  Future<Either<Failure, User>> configureWifi(WifiParams params) async {
    return await _requestUserAction(() {
      return remoteDataSource.configureWifi(params);
    });
  }

  Future<Either<Failure, User>> _requestUserAction(
    _RequestUserActionChooser requestUserAction,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await requestUserAction();
        return Right(remoteUser);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, User>> addFavouriteSensorById(String sensorId) async {
    return await _requestUserAction(() {
      return remoteDataSource.addFavouriteSensorById(sensorId);
    });
  }

  @override
  Future<Either<Failure, User>> updateSensorSettings(
      UpdateSensorParams params) async {
    return await _requestUserAction(() {
      return remoteDataSource.updateSensorSettings(params);
    });
  }

  @override
  Future<Either<Failure, User>> updateModuleSettings(
      UpdateModuleParams params) async {
    return await _requestUserAction(() {
      return remoteDataSource.updateModuleSettings(params);
    });
  }
}
