import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cult_connect/core/error/exception.dart';
import 'package:cult_connect/core/error/failure.dart';
import 'package:cult_connect/core/network/network_info.dart';
import 'package:cult_connect/features/login/data/datasources/user_local_data_source.dart';
import 'package:cult_connect/features/login/data/datasources/user_remote_data_source.dart';
import 'package:cult_connect/features/login/data/models/user_model.dart';
import 'package:cult_connect/features/login/data/repositories/user_repository_impl.dart';
import 'package:cult_connect/features/login/domain/entities/user.dart';

class MockRemoteDataSource extends Mock implements UserRemoteDataSource {}

class MockLocalDataSource extends Mock implements UserLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  UserRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('signIn', () {
    final tEmailAddress = "toto@gmail.com";
    final tPassword = "123456";

    final tUserModel = UserModel(
      userId: "123",
      emailAddress: tEmailAddress,
      token: "123",
    );
    final User tUser = tUserModel;

    runTestOnline(() {
      test(
        'should check if the device is online',
        () {
          // arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          // act
          repository.signIn(tEmailAddress, tPassword);
          // assert
          verify(mockNetworkInfo.isConnected);
        },
      );

      group('device is online', () {
        setUp(() {
          when(mockNetworkInfo.isConnected)
              .thenAnswer((realInvocation) async => true);
        });

        test(
          'should return remote data when the call to remote data source is successful',
          () async {
            // arrange
            when(mockRemoteDataSource.signIn(tEmailAddress, tPassword))
                .thenAnswer((_) async => tUser);
            // act
            final result = await repository.signIn(tEmailAddress, tPassword);
            // assert
            verify(mockRemoteDataSource.signIn(tEmailAddress, tPassword));
            expect(result, equals(Right(tUser)));
          },
        );

        test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
            // arrange
            when(mockRemoteDataSource.signIn(tEmailAddress, tPassword))
                .thenAnswer((_) async => tUserModel);
            // act
            await repository.signIn(tEmailAddress, tPassword);
            // assert
            verify(mockRemoteDataSource.signIn(tEmailAddress, tPassword));
            verify(mockLocalDataSource.cacheUser(tUser));
          },
        );

        test(
          'should return server failure when the call to remote data is unsuccessful',
          () async {
            // arrange
            when(mockRemoteDataSource.signIn(tEmailAddress, tPassword))
                .thenThrow(ServerException());
            // act
            final result = await repository.signIn(tEmailAddress, tPassword);
            // assert
            verify(mockRemoteDataSource.signIn(tEmailAddress, tPassword));
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          },
        );
      });
    });

    runTestOffline(() {
      group('device is offline', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        test(
          'should return offlineFailure when the device is offline ',
          () async {
            // act
            final result = await repository.signIn(tEmailAddress, tPassword);
            // assert
            expect(result, equals(Left(OfflineFailure())));
          },
        );
      });
    });
  });

  group('register', () {
    final tEmailAddress = "toto@gmail.com";
    final tPassword = "123456";
    final tPseudo = "toto";

    final tUser = UserModel(
      userId: "123",
      emailAddress: tEmailAddress,
      token: "123",
    );

    runTestOnline(() {
      test(
        'should check if the device is online',
        () {
          // arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          // act
          repository.register(tEmailAddress, tPassword);
          // assert
          verify(mockNetworkInfo.isConnected);
        },
      );

      group('device is online', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test(
          'should return remote data when the call to remote data source is successful',
          () async {
            // arrange
            when(mockRemoteDataSource.register(tEmailAddress, tPassword))
                .thenAnswer((_) async => tUser);
            // act
            final result = await repository.register(tEmailAddress, tPassword);
            // assert
            verify(mockRemoteDataSource.register(tEmailAddress, tPassword));
            expect(result, equals(Right(tUser)));
          },
        );

        test(
          'should return server failure when the call to remote data is unsuccessful',
          () async {
            // arrange
            when(mockRemoteDataSource.register(tEmailAddress, tPassword))
                .thenThrow(ServerException());
            // act
            final result = await repository.register(tEmailAddress, tPassword);
            // assert
            verify(mockRemoteDataSource.register(tEmailAddress, tPassword));
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          },
        );
      });
    });

    runTestOffline(() {
      group('device is offline', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        test(
          'should return offlineFailure when the device is offline ',
          () async {
            // act
            final result = await repository.register(tEmailAddress, tPassword);
            // assert
            expect(result, equals(Left(OfflineFailure())));
          },
        );
      });
    });
  });
}
