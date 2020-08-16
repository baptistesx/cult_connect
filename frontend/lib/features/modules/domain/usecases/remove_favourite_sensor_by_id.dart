import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../login/data/models/user_model.dart';
import '../repositories/modules_repository.dart';

class RemoveFavouriteSensorById implements UseCase<UserModel, String> {
  final ModulesRepository repository;

  RemoveFavouriteSensorById(this.repository);

  @override
  Future<Either<Failure, UserModel>> call(String sensorId) async {
    return await repository.removeFavouriteSensorById(sensorId);
  }
}
