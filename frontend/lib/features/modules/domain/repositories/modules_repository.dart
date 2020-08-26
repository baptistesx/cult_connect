import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../login/domain/entities/user.dart';
import '../../presentation/pages/dashboard_first_page.dart';
import '../../presentation/pages/sensor_datails_page.dart';
import '../entities/module.dart';
import '../usecases/add_module.dart';
import '../usecases/configure_wifi.dart';

abstract class ModulesRepository {
  Future<Either<Failure, List<Module>>> getModules(String token);
  Future<Either<Failure, User>> addModule(AddModuleParams params);
  Future<Either<Failure, User>> removeFavouriteSensorById(String sensorId);
  Future<Either<Failure, User>> addFavouriteSensorById(String sensorId);
  Future<Either<Failure, User>> configureWifi(WifiParams params);
  Future<Either<Failure, User>> updateSensorSettings(UpdateSensorParams params);
  Future<Either<Failure, User>> updateModuleSettings(UpdateModuleParams params);
}
