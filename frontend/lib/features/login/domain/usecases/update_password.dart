import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdatePassword implements UseCase<User, NoParams> {
  final UserRepository repository;

  UpdatePassword(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.updatePassword(NoParams());
  }
}
