import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../../main.dart';
import '../../../login/data/models/user_model.dart';
import '../../domain/entities/module.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../../presentation/pages/sensor_datails_page.dart';
import '../models/module_model.dart';

abstract class ModulesRemoteDataSource {
  Future<List<ModuleModel>> getModules(String token);
  Future<UserModel> addModule(AddModuleParams params);
  Future<UserModel> removeFavouriteSensorById(String sensorId);
  Future<UserModel> addFavouriteSensorById(String sensorId);
  Future<UserModel> configureWifi(WifiParams params);
  Future<UserModel> updateSensorSettings(UpdateSensorParams params);
  Future<UserModel> updateModuleSettings(UpdateModuleParams params);
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
      _postRequestUserFromUrlAndBody(
        '/api/addModule',
        {
          'publicId': params.publicId,
          'privateId': params.privateId,
          'name': params.name,
          'place': params.place,
          'routerSsid': params.routerSsid,
          'routerPassword': params.routerPassword
        },
      );

  @override
  Future<UserModel> removeFavouriteSensorById(String sensorId) async =>
      _postRequestUserFromUrlAndBody(
        '/api/removeFavouriteSensorById',
        {'sensorId': sensorId},
      );

  @override
  Future<UserModel> configureWifi(WifiParams params) =>
      _postRequestUserFromUrlAndBody(
        '/api/configureWifi',
        {
          'routerSsid': params.routerSsid,
          'routerPassword': params.routerPassword,
        },
      );

  Future<UserModel> _postRequestUserFromUrlAndBody(
      String url, dynamic body) async {
    final response = await client.post(SERVER_IP + url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': jwt
        },
        body: body);
    if (response.statusCode.toString()[0] == "2") {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> addFavouriteSensorById(String sensorId) async =>
      _postRequestUserFromUrlAndBody(
        '/api/addFavouriteSensorById',
        {'sensorId': sensorId},
      );

  @override
  Future<UserModel> updateSensorSettings(UpdateSensorParams params) async =>
      _postRequestUserFromUrlAndBody(
        '/api/updateSensorSettings',
        {'newName': params.newName, 'sensorId': params.sensorId},
      );

  @override
  Future<UserModel> updateModuleSettings(UpdateModuleParams params) =>
      _postRequestUserFromUrlAndBody(
        '/api/updateModuleSettings',
        {
          'newName': params.newName,
          'newPlace': params.newPlace,
          'moduleId': params.moduleId
        },
      );
}
