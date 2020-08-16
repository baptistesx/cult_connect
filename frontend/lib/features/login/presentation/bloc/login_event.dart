import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/usecases/sign_in.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const <dynamic>[]]) : super(props);
}

class LaunchSignIn extends LoginEvent {
  final LoginParams loginParams;

  LaunchSignIn(this.loginParams) : super([loginParams]);
}

class LaunchRegister extends LoginEvent {
  final LoginParams loginParams;

  LaunchRegister(this.loginParams) : super([loginParams]);
}

class LaunchSendVerificationCode extends LoginEvent {
  final String emailAddress;
  final String newPassword;

  LaunchSendVerificationCode(this.emailAddress, this.newPassword)
      : super([emailAddress, newPassword]);
}

class LaunchUpdatePassword extends LoginEvent {
  final String verificationCode;
  final String enteredCode;
  final LoginParams loginParams;

  LaunchUpdatePassword(
      this.verificationCode, this.enteredCode, this.loginParams)
      : super([verificationCode, enteredCode, loginParams]);
}
