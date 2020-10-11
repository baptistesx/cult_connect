import 'package:flutter/foundation.dart';

import '../../domain/entities/actuator.dart';
import '../../domain/entities/module.dart';
import '../../domain/entities/sensor.dart';
import 'actuator_model.dart';
import 'sensor_model.dart';

class ModuleModel extends Module {
  ModuleModel({
    @required String moduleId,
    @required String publicId,
    @required String privateId,
    @required bool state,
    @required String name,
    @required String place,
    @required bool used,
    @required List<Sensor> sensors,
    @required List<Actuator> actuators,
  }) : super(
          moduleId: moduleId,
          publicId: publicId,
          privateId: privateId,
          state: state,
          name: name,
          place: place,
          used: used,
          sensors: sensors,
          actuators: actuators,
        );

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      moduleId: json['_id'],
      publicId: json['publicID'],
      privateId: json['privateID'],
      state: json['state'],
      name: json['name'],
      place: json['place'],
      used: json['used'],
      sensors: json['sensors'] != null
          ? (json['sensors'] as List)
              .map((sensor) => SensorModel.fromJson(sensor))
              .toList()
          : new List(),
      actuators: json['actuators'] != null
          ? (json['actuators'] as List)
              .map((actuator) => ActuatorModel.fromJson(actuator))
              .toList()
          : new List(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'publicId': publicId,
      'privateId': privateId,
      'state': state,
      'name': name,
      'place': place,
      'used': used,
      'sensors': sensors,
      'actuators': actuators,
    };
  }
}
