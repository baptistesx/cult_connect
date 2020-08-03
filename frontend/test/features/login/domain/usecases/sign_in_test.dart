import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cult_connect/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:cult_connect/features/login/domain/repositories/user_repository.dart';
import 'package:cult_connect/features/login/domain/entities/user.dart';
import 'package:cult_connect/features/login/domain/usecases/sign_in.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  SignIn usecase;
  MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = SignIn(mockUserRepository);
  });

  final tEmailAddress = 'user@gmail.com';
  final tPassword = '123456';
  final tUser = User(
    userId: '123',
    emailAddress: 'user@gmail.com',
    token: '123456',
    //TODO: to uncomment
    // modules: List(),
  );

  test('should sign the user and get it', () async {
    when(mockUserRepository.signIn(any, any))
        .thenAnswer((_) async => Right(tUser));

    final result = await usecase(
      LoginParams(emailAddress: tEmailAddress, password: tPassword),
    );

    expect(result, Right(tUser));
    verify(mockUserRepository.signIn(tEmailAddress, tPassword));
    verifyNoMoreInteractions(mockUserRepository);
  });
}
