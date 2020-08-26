import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../login/domain/entities/user.dart';
import '../../presentation/pages/sensor_datails_page.dart';
import '../repositories/modules_repository.dart';

class UpdateSensorSettings implements UseCase<User, UpdateSensorParams> {
  final ModulesRepository repository;

  UpdateSensorSettings(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateSensorParams params) async {
    return await repository.updateSensorSettings(params);
  }
}
