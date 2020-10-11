import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import './bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../main.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_jwt.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/send_verification_code.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/update_password.dart';
import '../util/login_input_checker.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String EMAIL_ADDRESS_ALREADY_USED_FAILURE_MESSAGE =
    'This email address is already used.';
const String BAD_IDS_FAILURE_MESSAGE = 'Bad identifiers';
const String EMPTY_EMAIL_FAILURE_MESSAGE = 'Please fill in the email field';
const String INVALID_EMAIL_FAILURE_MESSAGE = 'Bad email address format.';
const String NOT_USED_EMAIL_ADDRESS_FAILURE_MESSAGE =
    'No user matches this email address.';
const String EMPTY_PASSWORD_FAILURE_MESSAGE =
    'Please fill in the password field';
const String INVALID_PASSWORD_FAILURE_MESSAGE =
    'Your password length must be over 6 characters';
const String EMPTY_VERIFICATION_CODE_FAILURE_MESSAGE =
    'Please fill in the verification code field';
const String INVALID_VERIFICATION_CODE_FAILURE_MESSAGE =
    'Bad verification code format';
const String VERIFICATION_CODE_NOT_MATCHING_FAILURE_MESSAGE =
    'The code does not match with the one we sent you';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GetJWT getJWT;
  final SignIn signIn;
  final Register register;
  final SendVerificationCode sendVerificationCode;
  final UpdatePassword updatePassword;
  final LoginInputChecker inputChecker;

  LoginBloc({
    @required GetJWT getJWT,
    @required SignIn signIn,
    @required Register register,
    @required SendVerificationCode verficiationCode,
    @required UpdatePassword updatePassword,
    @required LoginInputChecker checker,
  })  : assert(getJWT != null),
        assert(signIn != null),
        assert(register != null),
        assert(verficiationCode != null),
        assert(updatePassword != null),
        assert(checker != null),
        getJWT = getJWT,
        signIn = signIn,
        register = register,
        sendVerificationCode = verficiationCode,
        updatePassword = updatePassword,
        inputChecker = checker,
        super(null);

  LoginState get initialState => LoginEmpty();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LaunchAutoSignIn) {
      yield JWTCheckLoading();

      final failureOrUser = await signIn(jwt);
      yield failureOrUser.fold(
        (failure) => LoginEmpty(),
        (user) {
          globalUser = user;
          return LoginLoaded();
        },
      );
    } else if (event is LaunchSignIn) {
      final inputEither = inputChecker.signInCheck(event.loginParams);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (loginParams) async* {
          yield LoginLoading();

          final failureOrJWT = await getJWT(LoginParams(
            emailAddress: loginParams.emailAddress,
            password: loginParams.password,
          ));
          yield* failureOrJWT.fold(
            (failure) async* {
              yield* _streamFailure(failure);
            },
            (jwtReceived) async* {
              jwt = jwtReceived;
              storage.write(key: "jwt", value: jwt);
              print(jwt);
              final failureOrUser = await signIn(jwt);
              yield* _eitherLoadedOrErrorState(failureOrUser);
            },
          );
        },
      );
    } else if (event is LaunchSignOut) {
      globalUser.clearUser();
      storage.write(key: "jwt", value: "");
      jwt = "";
      yield LoginEmpty();
    } else if (event is LaunchRegister) {
      final inputEither = inputChecker.registerCheck(event.loginParams);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (loginParams) async* {
          yield LoginLoading();

          final failureOrJWT = await register(LoginParams(
            emailAddress: loginParams.emailAddress,
            password: loginParams.password,
          ));
          yield* failureOrJWT.fold(
            (failure) async* {
              yield* _streamFailure(failure);
            },
            (jwtReceived) async* {
              storage.write(key: "jwt", value: jwt);
              jwt = jwtReceived;

              final failureOrUser = await signIn(jwt);
              yield* _eitherLoadedOrErrorState(failureOrUser);
            },
          );
        },
      );
    } else if (event is LaunchSendVerificationCode) {
      final inputEither = inputChecker.passwordChecked(event.newPassword);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (_) async* {
          yield LoginLoading();
          final verificationCode =
              await sendVerificationCode(event.emailAddress);

          yield* verificationCode.fold(
            (failure) async* {
              yield LoginEmpty();
              yield LoginError(
                message: _mapFailureToMessage(failure),
              );
            },
            (code) async* {
              yield VerificationCodeLoaded(verificationCode: code);
            },
          );
        },
      );
    } else if (event is LaunchUpdatePassword) {
      final inputEither = inputChecker.verificationCodeCheck(
        event.verificationCode,
        event.enteredCode,
      );

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (_) async* {
          yield LoginLoading();
          final failureOrJWT = await updatePassword(event.loginParams);
          yield* failureOrJWT.fold(
            (failure) async* {
              yield* _streamFailure(failure);
            },
            (jwtReceived) async* {
              storage.write(key: "jwt", value: jwt);
              jwt = jwtReceived;
              final failureOrUser = await signIn(jwt);
              yield* _eitherLoadedOrErrorState(failureOrUser);
            },
          );
        },
      );
    }
  }

  Stream<LoginState> _streamFailure(Failure failure) async* {
    yield LoginEmpty();
    yield LoginError(message: _mapFailureToMessage(failure));
  }

  Stream<LoginState> _eitherLoadedOrErrorState(
      Either<Failure, User> either) async* {
    yield either.fold(
      (failure) => LoginError(message: _mapFailureToMessage(failure)),
      (user) {
        globalUser = user;
        return LoginLoaded();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      case EmptyEmailAddressFailure:
        return EMPTY_EMAIL_FAILURE_MESSAGE;
      case NotUsedEmailAddressFailure:
        return NOT_USED_EMAIL_ADDRESS_FAILURE_MESSAGE;
      case EmailAddressAlreadyUsedFailure:
        return EMAIL_ADDRESS_ALREADY_USED_FAILURE_MESSAGE;
      case InvalidEmailAddressFailure:
        return INVALID_EMAIL_FAILURE_MESSAGE;
      case EmptyPasswordFailure:
        return EMPTY_PASSWORD_FAILURE_MESSAGE;
      case InvalidPasswordFailure:
        return INVALID_PASSWORD_FAILURE_MESSAGE;
      case VerificationCodeNotMatchingFailure:
        return VERIFICATION_CODE_NOT_MATCHING_FAILURE_MESSAGE;
      case BadIdsFailure:
        return BAD_IDS_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
