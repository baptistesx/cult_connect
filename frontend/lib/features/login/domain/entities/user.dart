import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../modules/domain/entities/module.dart';

class User extends Equatable {
  String userId;
  String emailAddress;
  String routerSsid;
  String routerPassword;
  List<Module> modules;
  List favouriteSensors;

  User({
    @required this.userId,
    @required this.emailAddress,
    @required this.routerSsid,
    @required this.routerPassword,
    @required this.modules,
    @required this.favouriteSensors,
  }) : super([userId]);

  @override
  String toString() {
    return 'User(userId: $userId, emailAddress: $emailAddress, routerSsid: $routerSsid, routerPassword: $routerPassword, modules: $modules, favouriteSensors: $favouriteSensors)';
  }
}
