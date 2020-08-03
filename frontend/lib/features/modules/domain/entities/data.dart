import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Data extends Equatable {
  final DateTime date;
  final double value;

  Data({
    @required this.date,
    @required this.value,
  }) : super([date, value]);

  @override
  String toString() => 'Data(date: $date, value: $value)';
}
