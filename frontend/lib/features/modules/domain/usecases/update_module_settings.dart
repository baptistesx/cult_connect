import 'package:cult_connect/features/modules/domain/entities/module.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../login/domain/entities/user.dart';
import '../../presentation/pages/dashboard_first_page.dart';
import '../repositories/modules_repository.dart';

class UpdateModuleSettings implements UseCase<User, UpdateModuleParams> {
  final ModulesRepository repository;

  UpdateModuleSettings(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateModuleParams params) async {
    return await repository.updateModuleSettings(params);
  }
}
