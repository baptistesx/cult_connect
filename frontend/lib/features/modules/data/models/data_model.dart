import 'package:flutter/foundation.dart';

import '../../domain/entities/data.dart';

class DataModel extends Data {
  DataModel({
    @required DateTime date,
    @required double value,
  }) : super(
          date: date,
          value: value,
        );

  factory DataModel.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.parse(json['date']);

    return DataModel(
      date: date,
      value: json['value'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}
