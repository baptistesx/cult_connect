import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import './bloc.dart';
import '../../../../core/error/failure.dart';
import '../util/login_input_checker.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../main.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/send_verification_code.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/update_password.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String EMPTY_EMAIL_FAILURE_MESSAGE = 'Please fill in the email field';
const String INVALID_EMAIL_FAILURE_MESSAGE = 'Bad email address format.';
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
  final SignIn signIn;
  final Register register;
  final ConfigureWifi configureWifi;
  final SendVerificationCode sendVerificationCode;
  final UpdatePassword updatePassword;
  final LoginInputChecker inputChecker;

  LoginBloc({
    @required SignIn signIn,
    @required Register register,
    @required ConfigureWifi configuration,
    @required SendVerificationCode verficiationCode,
    @required UpdatePassword updatePassword,
    @required LoginInputChecker checker,
  })  : assert(signIn != null),
        assert(register != null),
        assert(configuration != null),
        assert(verficiationCode != null),
        assert(updatePassword != null),
        assert(checker != null),
        signIn = signIn,
        register = register,
        configureWifi = configuration,
        sendVerificationCode = verficiationCode,
        updatePassword = updatePassword,
        inputChecker = checker,
        super(null);

  LoginState get initialState => Empty();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LaunchSignIn) {
      final inputEither = inputChecker.signInCheck(event.loginParams);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (loginParams) async* {
          yield Loading();
          final failureOrUser = await signIn(LoginParams(
            emailAddress: loginParams.emailAddress,
            password: loginParams.password,
          ));
          yield* _eitherLoadedOrErrorState(failureOrUser);
        },
      );
    } else if (event is LaunchRegister) {
      final inputEither = inputChecker.registerCheck(event.loginParams);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (loginParams) async* {
          yield Loading();
          final failureOrUser = await register(LoginParams(
            emailAddress: loginParams.emailAddress,
            password: loginParams.password,
          ));
          yield* _eitherLoadedOrErrorState(failureOrUser);
        },
      );
    } else if (event is LaunchWifiConfiguration) {
      yield Loading();
      final failureOrUser = await configureWifi(WifiParams(
        routerSsid: event.wifiParams.routerSsid,
        routerPassword: event.wifiParams.routerPassword,
      ));
      yield* _eitherLoadedOrErrorState(failureOrUser);
    } else if (event is LaunchSendVerificationCode) {
      final inputEither = inputChecker.passwordChecked(event.newPassword);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (_) async* {
          yield Loading();
          final verificationCode =
              await sendVerificationCode(event.emailAddress);

          yield* verificationCode.fold(
            (failure) async* {
              yield Empty();
              yield Error(
                message: _mapFailureToMessage(failure),
              );
            },
            (code) async* {
              globalUser.emailAddress = event.emailAddress;
              globalUser.verificationCode = code;
              globalUser.newPassword = event.newPassword;
              yield VerificationCodeLoaded(verificationCode: code);
            },
          );
        },
      );
    } else if (event is LaunchUpdatePassword) {
      final inputEither = inputChecker.verificationCodeCheck(event.code);

      yield* inputEither.fold(
        (failure) async* {
          print("failure");
          yield* _streamFailure(failure);
        },
        (_) async* {
          yield Loading();
          final failureOrUser = await updatePassword(NoParams());
          yield* _eitherLoadedOrErrorState(failureOrUser);
        },
      );
    }
  }

  Stream<LoginState> _streamFailure(Failure failure) async* {
    yield Empty();
    yield Error(message: _mapFailureToMessage(failure));
  }

  Stream<LoginState> _eitherLoadedOrErrorState(
      Either<Failure, User> either) async* {
    yield either.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (user) {
        globalUser = user;
        return Loaded(user: user);
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
      case InvalidEmailAddressFailure:
        return INVALID_EMAIL_FAILURE_MESSAGE;
      case EmptyPasswordFailure:
        return EMPTY_PASSWORD_FAILURE_MESSAGE;
      case InvalidPasswordFailure:
        return INVALID_PASSWORD_FAILURE_MESSAGE;
      case VerificationCodeNotMatchingFailure:
        return VERIFICATION_CODE_NOT_MATCHING_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
