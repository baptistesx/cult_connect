import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/module.dart';
import '../repositories/modules_repository.dart';

class GetModules implements UseCase<List<Module>, String> {
  final ModulesRepository repository;

  GetModules(this.repository);

  @override
  Future<Either<Failure, List<Module>>> call(String token) async {
    return await repository.getModules(token);
  }
}
