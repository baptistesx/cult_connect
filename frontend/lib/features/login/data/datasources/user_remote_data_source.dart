import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../../main.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<String> getJWT(String emailAddress, String password);
  Future<UserModel> signIn(String jwt);
  Future<String> register(String emailAddress, String password);
  Future<String> sendVerificationCode(String emailAddress);
  Future<String> updatePassword(String emailAddress, String password);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({@required this.client});

  @override
  Future<String> getJWT(String emailAddress, String password) async {
    final String url =
        "$SERVER_IP/api/getJWT/?email=$emailAddress&pwd=$password";
    final response = await client.get(url);
print(json.decode(response.body)['jwt']);
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body)['jwt'];
      case 401:
        throw BadIdsException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<UserModel> signIn(String jwt) =>
      _postRequestUserFromUrlAndBody('/api/signIn', {});

  @override
  Future<String> register(String emailAddress, String password) async {
    final response = await client.post(
      SERVER_IP + '/api/signUp',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'email': emailAddress,
        'pwd': password,
      },
    );

    switch (response.statusCode) {
      case 201:
        return json.decode(response.body)['jwt'];
      case 409:
        throw EmailAddressAlreadyUsedException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<String> updatePassword(String emailAddress, String newPassword) async {
    final String url = "$SERVER_IP/api/updatePassword";
    final response = await client.post(
      SERVER_IP + "/api/updatePassword",
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'emailAddress': emailAddress,
        'newPassword': newPassword,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['jwt'];
    } else {
      throw ServerException();
    }
  }

  Future<UserModel> _postRequestUserFromUrlAndBody(
      String url, dynamic body) async {
    final response = await client.post(SERVER_IP + url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': jwt
        },
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

    switch (response.statusCode) {
      case 200:
        return json['verificationCode'];
      case 409:
        throw NotUsedEmailAddressException();
      default:
        throw ServerException();
    }
  }
}
