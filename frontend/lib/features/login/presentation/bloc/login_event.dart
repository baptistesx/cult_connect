import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/usecases/configure_wifi.dart';
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

class LaunchWifiConfiguration extends LoginEvent {
  final WifiParams wifiParams;

  LaunchWifiConfiguration(this.wifiParams) : super([wifiParams]);
}

class LaunchSendVerificationCode extends LoginEvent {
  final String emailAddress;
  final String newPassword;

  LaunchSendVerificationCode(this.emailAddress, this.newPassword)
      : super([emailAddress, newPassword]);
}

class LaunchUpdatePassword extends LoginEvent {
  final String code;

  LaunchUpdatePassword(this.code) : super([code]);
}
