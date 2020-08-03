import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cult_connect/core/error/exception.dart';
import 'package:cult_connect/features/login/data/datasources/user_local_data_source.dart';
import 'package:cult_connect/features/login/data/models/user_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  UserLocalDataSource dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = UserLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getUserInCache', () {
    final tUserModel = UserModel.fromJson(json.decode(fixture('user.json')));

    test(
      'should return User from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('user.json'));
        // act
        final result = await dataSource.getUserInCache();
        // assert
        verify(mockSharedPreferences.getString('CACHED_USER'));
        expect(result, equals(tUserModel));
      },
    );

    test(
      'should throw a CacheException when there is not a cached value',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        // act
        final call = dataSource.getUserInCache;
        // assert
        expect(() => call(),
            throwsA(isInstanceOf<CacheException>()));
      },
    );
  });

  group('cacheUser', () {
    final tUserModel = UserModel(
      emailAddress: 'toto@gmail.com',
      token: '1234',
      userId: '123', favouriteSensors: [],
    );

    test(
      'should call SharedPreferences to cache the user',
      () async {
        // act
        dataSource.cacheUser(tUserModel);
        // assert
        final expectedJsonString = json.encode(tUserModel.toJson());
        verify(mockSharedPreferences.setString(
          CACHED_USER,
          expectedJsonString,
        ));
      },
    );
  });
}
