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
    @required String name,
    @required String place,
    @required bool used,
    @required Map<String, Sensor> sensors,
    @required List<Actuator> actuators,
  }) : super(
          moduleId: moduleId,
          publicId: publicId,
          privateId: privateId,
          name: name,
          place: place,
          used: used,
          sensors: sensors,
          actuators: actuators,
        );

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      moduleId: json['moduleId'],
      publicId: json['publicId'],
      privateId: json['privateId'],
      name: json['name'],
      place: json['place'],
      used: json['used'],
      sensors: json['sensors'] != null
          ? (json['sensors'] as Map<String, dynamic>).map((sensorId, sensor) {
              return MapEntry<String, SensorModel>(
                  sensorId, SensorModel.fromJson(sensor));
            })
          : new Map<String, Sensor>(),
      actuators: json['actuators'] != null
          ? (json['actuators'] as List)
              .map((actuator) => ActuatorModel.fromJson(actuator))
              .toList()
          : new List(),
    );
  }
  Map<String, dynamic> toJson() {
    Map<dynamic, dynamic> sensors = this
        .sensors
        .map((id, sensor) => MapEntry(id, (sensor as SensorModel).toJson()));

    return {
      'moduleId': moduleId,
      'publicId': publicId,
      'privateId': privateId,
      'name': name,
      'place': place,
      'used': used,
      'sensors': sensors,
      'actuators': actuators,
    };
  }
}
