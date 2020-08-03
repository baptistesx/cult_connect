import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../login/domain/entities/user.dart';
import '../entities/module.dart';
import '../usecases/add_module.dart';

abstract class ModulesRepository {
  Future<Either<Failure, List<Module>>> getModules(String token);
  Future<Either<Failure, User>> addModule(AddModuleParams params);
}
