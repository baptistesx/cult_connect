import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../login/data/models/user_model.dart';
import '../../../login/domain/entities/user.dart';
import '../entities/module.dart';
import '../usecases/add_module.dart';
import '../usecases/configure_wifi.dart';

abstract class ModulesRepository {
  Future<Either<Failure, List<Module>>> getModules(String token);
  Future<Either<Failure, User>> addModule(AddModuleParams params);
  Future<Either<Failure, UserModel>> removeFavouriteSensorById(String sensorId);
  Future<Either<Failure, User>> configureWifi(WifiParams params);
}
