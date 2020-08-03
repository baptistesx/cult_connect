import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cult_connect/core/error/exception.dart';
import 'package:cult_connect/features/login/data/datasources/user_remote_data_source.dart';
import 'package:cult_connect/features/login/data/models/user_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  UserRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = UserRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer(
      (_) async => http.Response(fixture('user.json'), 200),
    );
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer(
      (_) async => http.Response('Something went wrong', 404),
    );
  }

  group('signIn', () {
    final tEmailAddress = 'toto@gmail.com';
    final tPassword = '123456';
    final tUserId = '123';
    final tToken = '1234';
    final tPseudo = 'toto';

    final tUserModel = UserModel.fromJson(json.decode(fixture('user.json')));
    test(
      'should perform a POST request to the right signin endpoint and with application/json header ',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        dataSource.signIn(tEmailAddress, tPassword);
        // assert
        verify(mockHttpClient.post(
          'http://10.0.2.2:8081/api/signIn',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            "email": tEmailAddress,
            "pwd": tPassword,
          },
        ));
      },
    );

    test(
      'should return the User when the response code from singingin is 200',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await dataSource.signIn(tEmailAddress, tPassword);
        // assert
        expect(result, equals(tUserModel));
      },
    );

    test(
      'should throw a ServerException when the response code from registering is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = dataSource.signIn;
        // assert
        expect(() => call(tEmailAddress, tPassword),
            throwsA(isInstanceOf<ServerException>()));
      },
    );
  });

  group('register', () {
    final tEmailAddress = 'toto@gmail.com';
    final tPassword = '123456';
    final tUserId = '123';
    final tToken = '1234';
    final tPseudo = 'toto';

    final tUserModel = UserModel.fromJson(json.decode(fixture('user.json')));
    test(
      'should perform a POST request to the right register endpoint and with application/json header ',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        dataSource.register(tEmailAddress, tPassword);
        // assert
        verify(mockHttpClient.post(
          'http://10.0.2.2:8081/api/register',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            "email": tEmailAddress,
            "pwd": tPassword,
          },
        ));
      },
    );

    test(
      'should return the User when the response code from registering is 200',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result =
            await dataSource.register(tEmailAddress, tPassword);

        // assert
        expect(result, equals(tUserModel));
      },
    );

    test(
      'should throw a ServerException when the response code from registering is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = dataSource.register;

        // assert
        expect(() => call(tEmailAddress, tPassword),
            throwsA(isInstanceOf<ServerException>()));
      },
    );
  });
}
