import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:cult_connect/features/login/data/models/user_model.dart';
import 'package:cult_connect/features/login/domain/entities/user.dart';
import 'package:cult_connect/features/modules/domain/entities/module.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tUserModel = UserModel(
    userId: '123',
    emailAddress: 'toto@gmail.com',
    token: '123456',
    //TODO: to uncomment
    // modules: List<Module>(),
  );

  test('should be a subclass of User entity', () async {
    expect(tUserModel, isA<User>());
  });

  test(
    'should  return a valid model from JSON',
    () async {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('user.json'));
      // act
      final result = UserModel.fromJson(jsonMap);
      // assert
      expect(result, tUserModel);
    },
  );

  test(
    'should return a JSON map containing the proper data ',
    () async {
      // act
      final result = tUserModel.toJson();
      // assert
      final expectedJsonMap = {
        "userId": "123",
        "emailAddress": "toto@gmail.com",
        "token": "123456",
        "pseudo": "toto"
      };
      expect(result, expectedJsonMap);
    },
  );
}
