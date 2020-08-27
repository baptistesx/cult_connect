import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../login/domain/entities/user.dart';
import '../repositories/modules_repository.dart';

class AddModule implements UseCase<User, AddModuleParams> {
  final ModulesRepository repository;

  AddModule(this.repository);

  @override
  Future<Either<Failure, User>> call(AddModuleParams params) async {
    return await repository.addModule(params);
  }
}

class AddModuleParams extends Equatable {
  String publicId;
  String privateId;
  String name;
  String place;
  String routerSsid;
  String routerPassword;

  AddModuleParams({
    @required this.publicId,
    @required this.privateId,
    @required this.name,
    @required this.place,
    @required this.routerSsid,
    @required this.routerPassword,
  }) : super([
          publicId,
          privateId,
        ]);

  @override
  String toString() {
    return 'AddModuleParams(publicId: $publicId, privateId: $privateId, name: $name, place: $place, routerSsid: $routerSsid, routerPassword: $routerPassword)';
  }
}
