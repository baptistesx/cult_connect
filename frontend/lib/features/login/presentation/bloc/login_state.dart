import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';

@immutable
abstract class LoginState extends Equatable {
  LoginState([List props = const <dynamic>[]]) : super(props);
}

class LoginEmpty extends LoginState {}

class LoginLoading extends LoginState {}

class LoginLoaded extends LoginState {
  final User user;

  LoginLoaded({@required this.user}) : super([user]);
}

class VerificationCodeLoaded extends LoginState {
  final String verificationCode;

  VerificationCodeLoaded({@required this.verificationCode})
      : super([verificationCode]);
}

class LoginError extends LoginState {
  final String message;

  LoginError({@required this.message}) : super([message]);
}
