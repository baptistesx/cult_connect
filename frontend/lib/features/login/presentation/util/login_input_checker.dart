import 'package:dartz/dartz.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/util/input_checker.dart';
import '../../domain/usecases/sign_in.dart';

class LoginInputChecker extends InputChecker {
  Either<Failure, LoginParams> signInCheck(LoginParams loginParams) {
    final email = emailAddressChecked(loginParams.emailAddress);

    return email.fold((failure) => Left(failure), (_) {
      final password = passwordChecked(loginParams.password);
      return password.fold(
          (failure) => Left(failure), (_) => Right(loginParams));
    });
  }

  //TODO: See if it could be useful in the future (if more fields to register)
  Either<Failure, LoginParams> registerCheck(LoginParams loginParams) =>
      signInCheck(loginParams);

  Either<Failure, String> emailAddressChecked(String emailAddress) {
    if (emailAddress == null) {
      return Left(EmptyEmailAddressFailure());
    } else if (emailAddress.length == 0) {
      return Left(EmptyEmailAddressFailure());
    }
    if (RegExp(EMAIL_REGEX).hasMatch(emailAddress)) {
      return Right(emailAddress);
    } else {
      return Left(InvalidEmailAddressFailure());
    }
  }

  Either<Failure, String> passwordChecked(String password) {
    if (password == null) {
      return Left(EmptyPasswordFailure());
    } else if (password.length == 0) {
      return Left(EmptyPasswordFailure());
    }
    if (password.length >= 6) {
      return Right(password);
    } else {
      throw Left(InvalidPasswordFailure());
    }
  }

  Either<Failure, String> verificationCodeCheck(
      String verificationCode, String enteredCode) {
    if (verificationCode != enteredCode) {
      return Left(VerificationCodeNotMatchingFailure());
    } else {
      return Right(verificationCode);
    }
  }
}
