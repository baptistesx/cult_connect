import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/module.dart';

abstract class ModuleState extends Equatable {
  ModuleState([List props = const <dynamic>[]]) : super(props);
}

class Empty extends ModuleState {}

class Loading extends ModuleState {}

class Loaded extends ModuleState {
  final List<Module> modules;

  Loaded({@required this.modules}) : super([modules]);
}

class Error extends ModuleState {
  final String message;

  Error({@required this.message}) : super([message]);
}

class RouterIdsError extends ModuleState {
  final String message;

  RouterIdsError({@required this.message}) : super([message]);
}

class SensorDetailsDisplayed extends ModuleState {
  final bool showSettings;

  SensorDetailsDisplayed({@required this.showSettings}) : super([showSettings]);
}

class LoadingWhileUpdatingModule extends ModuleState {
  LoadingWhileUpdatingModule() : super([]);
}
