import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:cult_connect/features/login/domain/entities/user.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/module_model.dart';
import '../entities/module.dart';
import '../repositories/modules_repository.dart';

class AddModule implements UseCase<User, AddModuleParams> {
  final ModulesRepository repository;

  AddModule(this.repository);

  @override
  Future<Either<Failure, User>> call(
      AddModuleParams params) async {
    return await repository.addModule(params);
  }
}

class AddModuleParams extends Equatable {
  String token;
  String publicId;
  String privateId;
  String name;
  String place;

  AddModuleParams({
    @required this.token,
    @required this.publicId,
    @required this.privateId,
    @required this.name,
    @required this.place,
  }) : super([
          publicId,
          privateId,
        ]);

  @override
  String toString() {
    return 'AddModuleParams(token: $token, publicId: $publicId, privateId: $privateId, name: $name, place: $place)';
  }
}
