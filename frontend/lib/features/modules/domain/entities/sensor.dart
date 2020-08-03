import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'actuator.dart';
import 'data.dart';

class Sensor extends Equatable {
  String sensorId;
  String name;
  String dataType;
  String unit;
  double acceptableMin;
  double acceptableMax;
  double criticalMin;
  double criticalMax;
  double nominalValue;
  double limitMin;
  double limitMax;
  bool automaticMode;
  bool isFavourite;
  List<Data> data;
  List<Actuator> actuators;

  Sensor({
    @required this.sensorId,
    @required this.name,
    @required this.dataType,
    @required this.unit,
    @required this.acceptableMin,
    @required this.acceptableMax,
    @required this.criticalMin,
    @required this.criticalMax,
    @required this.nominalValue,
    @required this.limitMin,
    @required this.limitMax,
    @required this.automaticMode,
    @required this.isFavourite,
    @required this.data,
    @required this.actuators,
  }) : super([]);

  @override
  String toString() {
    return 'Sensor(sensorId: $sensorId, name: $name, dataType: $dataType, unit: $unit, acceptableMin: $acceptableMin, acceptableMax: $acceptableMax, criticalMin: $criticalMin, criticalMax: $criticalMax, nominalValue: $nominalValue, limitMin: $limitMin, limitMax: $limitMax, automaticMode: $automaticMode, isFavourite: $isFavourite, data: $data, actuators: $actuators)';
  }
}
