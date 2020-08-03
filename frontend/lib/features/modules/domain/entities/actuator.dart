import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Actuator extends Equatable {
  final String actuatorId;
  String name;
  bool automaticMode;
  bool state;
  bool hasVariableValue;
  double value;
  DateTime startTime;
  DateTime stopTime;

  Actuator({
    @required this.actuatorId,
    @required this.name,
    @required this.automaticMode,
    @required this.state,
    @required this.hasVariableValue,
    @required this.value,
    @required this.startTime,
    @required this.stopTime,
  }) : super([actuatorId]);

  @override
  String toString() {
    return 'Actuator(actuatorId: $actuatorId, name: $name, automaticMode: $automaticMode, state: $state, hasVariableValue: $hasVariableValue, value: $value, startTime: $startTime, stopTime: $stopTime)';
  }
}
