import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../login/domain/entities/user.dart';
import '../repositories/modules_repository.dart';

class AddFavouriteSensorById implements UseCase<User, String> {
  final ModulesRepository repository;

  AddFavouriteSensorById(this.repository);

  @override
  Future<Either<Failure, User>> call(String sensorId) async {
    return await repository.addFavouriteSensorById(sensorId);
  }
}
