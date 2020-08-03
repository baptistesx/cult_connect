import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_repository.dart';

class SendVerificationCode implements UseCase<String, String> {
  final UserRepository repository;

  SendVerificationCode(this.repository);

  @override
  Future<Either<Failure, String>> call(String emailAddress) async {
    return await repository.sendVerificationCode(emailAddress);
  }
}
