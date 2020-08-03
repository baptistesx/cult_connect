import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../login/data/models/user_model.dart';
import '../../../login/domain/entities/user.dart';
import '../../domain/usecases/add_module.dart';
import '../models/module_model.dart';

abstract class ModulesRemoteDataSource {
  Future<List<ModuleModel>> getModules(String token);
  Future<User> addModule(AddModuleParams params);
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
  Future<User> addModule(AddModuleParams params) async {
    final response = await client.post(
      SERVER_IP + '/api/addModule',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': params.token
      },
      body: {
        'publicId': params.publicId,
        'privateId': params.privateId,
        'name': params.name,
        'place': params.place,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
