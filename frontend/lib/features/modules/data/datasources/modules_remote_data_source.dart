import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../../main.dart';
import '../../../login/data/models/user_model.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../models/module_model.dart';

abstract class ModulesRemoteDataSource {
  Future<List<ModuleModel>> getModules(String token);
  Future<UserModel> addModule(AddModuleParams params);
  Future<UserModel> removeFavouriteSensorById(String sensorId);
  Future<UserModel> configureWifi(WifiParams params);
}

class ModulesRemoteDataSourceImpl implements ModulesRemoteDataSource {
  final http.Client client;

  ModulesRemoteDataSourceImpl({@required this.client});

  @override
  Future<List<ModuleModel>> getModules(String token) async {
    final response = await client.post(
      SERVER_IP + '/api/getModules',
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed
          .map<ModuleModel>((json) => ModuleModel.fromJson(json))
          .toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> addModule(AddModuleParams params) async =>
      _requestUserFromUrlAndBody(
        '/api/addModule',
        {
          'publicId': params.publicId,
          'privateId': params.privateId,
          'name': params.name,
          'place': params.place,
        },
      );

  @override
  Future<UserModel> removeFavouriteSensorById(String sensorId) async =>
      _requestUserFromUrlAndBody(
        '/api/removeFavouriteSensorById',
        {'sensorId': sensorId},
      );

  @override
  Future<UserModel> configureWifi(WifiParams params) =>
      _requestUserFromUrlAndBody(
        '/api/configureWifi',
        {
          'routerSsid': params.routerSsid,
          'routerPassword': params.routerPassword,
        },
      );

  Future<UserModel> _requestUserFromUrlAndBody(String url, dynamic body) async {
    final response = await client.post(SERVER_IP + url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': globalUser.token
        },
        body: body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
