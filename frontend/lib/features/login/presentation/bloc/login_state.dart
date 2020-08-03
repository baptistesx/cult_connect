import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';

@immutable
abstract class LoginState extends Equatable {
  LoginState([List props = const <dynamic>[]]) : super(props);
}

class Empty extends LoginState {}

class Loading extends LoginState {}

class Loaded extends LoginState {
  final User user;

  Loaded({@required this.user}) : super([user]);
}

class VerificationCodeLoaded extends LoginState {
  final String verificationCode;

  VerificationCodeLoaded({@required this.verificationCode})
      : super([verificationCode]);
}

class Error extends LoginState {
  final String message;

  Error({@required this.message}) : super([message]);
}
