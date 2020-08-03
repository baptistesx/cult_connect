import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../main.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> signIn(String emailAddress, String password);
  Future<UserModel> register(String emailAddress, String password);
  Future<UserModel> configureWifi(WifiParams params);
  Future<String> sendVerificationCode(String emailAddress);
  Future<UserModel> updatePassword(NoParams params);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({@required this.client});

  @override
  Future<UserModel> signIn(String emailAddress, String password) =>
      _requestUserFromUrlAndBody(
        '/api/signIn',
        {
          'email': emailAddress,
          'pwd': password,
        },
      );

  @override
  Future<UserModel> register(String emailAddress, String password) =>
      _requestUserFromUrlAndBody(
        '/api/register',
        {
          'email': emailAddress,
          'pwd': password,
        },
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

  @override
  Future<UserModel> updatePassword(NoParams params) =>
      _requestUserFromUrlAndBody(
        '/api/updatePassword',
        {
          'email': globalUser.emailAddress,
          'newPassword': globalUser.newPassword,
        },
      );

  Future<UserModel> _requestUserFromUrlAndBody(String url, dynamic body) async {
    final response = await client.post(SERVER_IP + url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  Future<String> sendVerificationCode(String emailAddress) async {
    final response = await client.post(
      SERVER_IP + '/api/sendVerificationCode',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'emailAddress': emailAddress,
      },
    );

    final json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return json['verificationCode'];
    } else {
      throw ServerException();
    }
  }
}
