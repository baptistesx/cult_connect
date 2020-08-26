import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'actuator.dart';
import 'sensor.dart';

class Module extends Equatable {
  final String moduleId;
  final String publicId;
  final String privateId;
  String name;
  String place;
  bool used;
  Map<String, Sensor> sensors;
  List<Actuator> actuators;

  Module({
    @required this.moduleId,
    @required this.publicId,
    @required this.privateId,
    @required this.name,
    @required this.place,
    @required this.used,
    @required this.sensors,
    @required this.actuators,
  }) : super([moduleId]);

  @override
  String toString() {
    return 'Module(moduleId: $moduleId, publicId: $publicId, privateId: $privateId, name: $name, place: $place, used: $used, sensors: $sensors, actuators: $actuators)';
  }
}

class UpdateModuleParams {
  String moduleId;
  String newName;
  String newPlace;

  UpdateModuleParams({
    @required this.moduleId,
    @required this.newName,
    @required this.newPlace,
  });
}
