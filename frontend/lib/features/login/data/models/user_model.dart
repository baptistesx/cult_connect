import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../modules/data/models/module_model.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    @required String userId,
    @required String emailAddress,
    @required String token,
    @required String routerSsid,
    @required String routerPassword,
    @required List<ModuleModel> modules,
    @required List favouriteSensors,
  }) : super(
          userId: userId,
          emailAddress: emailAddress,
          token: token,
          routerSsid: routerSsid,
          routerPassword: routerPassword,
          modules: modules,
          favouriteSensors: favouriteSensors,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      emailAddress: json['emailAddress'],
      token: json['token'],
      routerSsid: json['routerSsid'],
      routerPassword: json['routerPassword'],
      modules: json['modules'] != []
          ? (json['modules'] as List)
              .map((module) => ModuleModel.fromJson(module))
              .toList()
          : new List(),
      favouriteSensors: json['favouriteSensors'] != []
          ? json['favouriteSensors'] as List
          : new List(),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map> modules =
        this.modules.map((module) => (module as ModuleModel).toJson()).toList();
    return {
      'userId': userId,
      'emailAddress': emailAddress,
      'token': token,
      'routerSsid': routerSsid,
      'routerPassword': routerPassword,
      'modules': modules,
      'favouriteSensors': jsonEncode(favouriteSensors),
    };
  }
}
