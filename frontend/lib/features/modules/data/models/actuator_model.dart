import 'package:flutter/foundation.dart';

import '../../domain/entities/actuator.dart';

class ActuatorModel extends Actuator {
  ActuatorModel({
    @required String actuatorId,
    @required String name,
    @required bool automaticMode,
    @required bool state,
    @required bool hasVariableValue,
    @required double value,
    @required DateTime startTime,
    @required DateTime stopTime,
  }) : super(
          actuatorId: actuatorId,
          name: name,
          automaticMode: automaticMode,
          state: state,
          hasVariableValue: hasVariableValue,
          value: value,
          startTime: startTime,
          stopTime: stopTime,
        );

  factory ActuatorModel.fromJson(Map<String, dynamic> json) {
    return ActuatorModel(
      actuatorId: json['actuatorId'],
      name: json['name'],
      automaticMode: json['automaticMode'],
      state: json['state'],
      hasVariableValue: json['hasVariableValue'],
      value: json['value'],
      startTime: json['startTime'],
      stopTime: json['stopTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actuatorId': actuatorId,
      'name': name,
      'automaticMode': automaticMode,
      'state': state,
      'hasVariableValue': hasVariableValue,
      'value': value,
      'startTime': startTime,
      'stopTime': stopTime,
    };
  }
}
