import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../login/domain/entities/user.dart';
import '../repositories/modules_repository.dart';

class ConfigureWifi implements UseCase<User, WifiParams> {
  final ModulesRepository repository;

  ConfigureWifi(this.repository);

  @override
  Future<Either<Failure, User>> call(WifiParams params) async {
    return await repository.configureWifi(params);
  }
}

class WifiParams extends Equatable {
  String routerSsid;
  String routerPassword;

  WifiParams({
    @required this.routerSsid,
    @required this.routerPassword,
  }) : super([routerSsid, routerPassword]);

  @override
  String toString() =>
      'WifiParams(ssid: $routerSsid, password: $routerPassword)';
}
