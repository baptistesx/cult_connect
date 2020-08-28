import 'package:equatable/equatable.dart';

import '../../features/login/presentation/bloc/bloc.dart';
import '../../features/modules/presentation/bloc/bloc.dart';

abstract class Failure extends Equatable {
  Failure([List properties = const <dynamic>[]]) : super(properties);
}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class OfflineFailure extends Failure {}

// Input failures
class BadIdsFailure extends Failure {
  @override
  String get getFailureMessage => BAD_IDS_FAILURE_MESSAGE;
}

class InvalidEmailAddressFailure extends Failure {
  @override
  String get getFailureMessage => INVALID_EMAIL_FAILURE_MESSAGE;
}

class NotUsedEmailAddressFailure extends Failure {
  @override
  String get getFailureMessage => NOT_USED_EMAIL_ADDRESS_FAILURE_MESSAGE;
}

class EmptyEmailAddressFailure extends Failure {
  @override
  String get getFailureMessage => EMPTY_EMAIL_FAILURE_MESSAGE;
}

class EmailAddressAlreadyUsedFailure extends Failure {
  @override
  String get getFailureMessage => EMAIL_ADDRESS_ALREADY_USED_FAILURE_MESSAGE;
}

class InvalidPasswordFailure extends Failure {
  @override
  String get getFailureMessage => INVALID_PASSWORD_FAILURE_MESSAGE;
}

class EmptyPasswordFailure extends Failure {
  @override
  String get getFailureMessage => EMPTY_PASSWORD_FAILURE_MESSAGE;
}

class InvalidPublicIdFailure extends Failure {
  @override
  String get getFailureMessage => INVALID_PUBLIC_ID_FAILURE_MESSAGE;
}

class InvalidPrivateIdFailure extends Failure {
  @override
  String get getFailureMessage => INVALID_PRIVATE_ID_FAILURE_MESSAGE;
}

class InvalidNameFailure extends Failure {
  @override
  String get getFailureMessage => INVALID_NAME_FAILURE_MESSAGE;
}

class InvalidPlaceFailure extends Failure {
  @override
  String get getFailureMessage => INVALID_PLACE_FAILURE_MESSAGE;
}

class VerificationCodeNotMatchingFailure extends Failure {
  @override
  String get getFailureMessage =>
      VERIFICATION_CODE_NOT_MATCHING_FAILURE_MESSAGE;
}
