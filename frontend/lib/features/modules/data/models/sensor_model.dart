import 'package:flutter/cupertino.dart';

import '../../domain/entities/actuator.dart';
import '../../domain/entities/data.dart';
import '../../domain/entities/sensor.dart';
import 'actuator_model.dart';
import 'data_model.dart';

class SensorModel extends Sensor {
  SensorModel({
    @required String sensorId,
    @required String name,
    @required String dataType,
    @required String unit,
    @required double acceptableMin,
    @required double acceptableMax,
    @required double criticalMin,
    @required double criticalMax,
    @required double nominalValue,
    @required double limitMin,
    @required double limitMax,
    @required bool automaticMode,
    @required bool isFavourite,
    @required List<Data> data,
    @required List<Actuator> actuators,
  }) : super(
          sensorId: sensorId,
          name: name,
          dataType: dataType,
          unit: unit,
          acceptableMin: acceptableMin,
          acceptableMax: acceptableMax,
          criticalMin: criticalMin,
          criticalMax: criticalMax,
          nominalValue: nominalValue,
          limitMin: limitMin,
          limitMax: limitMax,
          automaticMode: automaticMode,
          isFavourite: isFavourite,
          data: data,
          actuators: actuators,
        );

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      sensorId: json['sensorId'],
      name: json['name'],
      dataType: json['dataType'],
      unit: json['unit'],
      acceptableMin: json['acceptableMin'].toDouble(),
      acceptableMax: json['acceptableMax'].toDouble(),
      criticalMin: json['criticalMin'].toDouble(),
      criticalMax: json['criticalMax'].toDouble(),
      nominalValue: json['nominalValue'].toDouble(),
      limitMin: json['limitMin'].toDouble(),
      limitMax: json['limitMax'].toDouble(),
      automaticMode: json['automaticMode'],
      isFavourite: json['isFavourite'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((data) => DataModel.fromJson(data))
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
    List<Map> data =
        this.data.map((data) => (data as DataModel).toJson()).toList();

    return {
      'sensorId': sensorId,
      'name': name,
      'dataType': dataType,
      'unit': unit,
      'acceptableMin': acceptableMin,
      'acceptableMax': acceptableMax,
      'criticalMin': criticalMin,
      'criticalMax': criticalMax,
      'nominalValue': nominalValue,
      'limitMin': limitMin,
      'limitMax': limitMax,
      'automaticMode': automaticMode,
      'isFavourite': isFavourite,
      'data': data,
      'actuators': actuators,
    };
  }
}
