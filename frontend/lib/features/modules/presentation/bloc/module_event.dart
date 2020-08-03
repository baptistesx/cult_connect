import 'package:equatable/equatable.dart';

import '../../domain/usecases/add_module.dart';

abstract class ModuleEvent extends Equatable {
  ModuleEvent([List props = const <dynamic>[]]) : super(props);
}

class LaunchAddModule extends ModuleEvent{
  final AddModuleParams addModuleParams;

  LaunchAddModule(this.addModuleParams): super([addModuleParams]);
}