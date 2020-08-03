import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cult_connect/core/error/failure.dart';
import 'package:cult_connect/features/login/presentation/util/login_input_checker.dart';
import 'package:cult_connect/features/login/domain/entities/user.dart';
import 'package:cult_connect/features/login/domain/usecases/register.dart';
import 'package:cult_connect/features/login/domain/usecases/sign_in.dart';
import 'package:cult_connect/features/login/presentation/bloc/bloc.dart';

class MockSignIn extends Mock implements SignIn {}

class MockRegister extends Mock implements Register {}

class MockInputChecker extends Mock implements InputChecker {}

void main() {
  LoginBloc bloc;
  MockSignIn mockSignIn;
  MockRegister mockRegister;
  MockInputChecker mockInputChecker;

  setUp(() {
    mockSignIn = MockSignIn();
    mockRegister = MockRegister();
    mockInputChecker = MockInputChecker();

    bloc = LoginBloc(
      signIn: mockSignIn,
      register: mockRegister,
      checker: mockInputChecker,
    );
  });

  test('initialState should be Empty', () {
    //asser
    expect(bloc.initialState, equals(Empty()));
  });

  group('signIn', () {
    final tEmailAddress = 'toto@gmail.com';
    final tPassword = '123456';
    final tUserId = '123';
    final tToken = '1234';
    final tPseudo = 'toto';

    final tloginParams = LoginParams(
      emailAddress: tEmailAddress,
      password: tPassword,
    );

    final tUser = User(
      userId: tUserId,
      emailAddress: tEmailAddress,
      token: tToken,
    );

    void setUpMockSignInInputChecker() =>
        when(mockInputChecker.signInCheck(tloginParams))
            .thenReturn(Right(tloginParams));

    test(
      'should call the InputChecker to validate the loginParams',
      () async {
        // arrange
        setUpMockSignInInputChecker();
        // act
        bloc.add(LaunchSignIn(tloginParams));
        await untilCalled(mockInputChecker.signInCheck(any));
        // assert
        verify(mockInputChecker.signInCheck(tloginParams));
      },
    );

    test(
      'should emit [Error] when the emailAddress is invalid',
      () async {
        // arrange
        when(mockInputChecker.signInCheck(any))
            .thenReturn(Left(InvalidEmailAddressFailure()));
        // assert late
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_EMAIL_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchSignIn(tloginParams));
      },
    );

    test(
      'should emit [Error] when the password is invalid',
      () async {
        // arrange
        when(mockInputChecker.signInCheck(any))
            .thenReturn(Left(InvalidPasswordFailure()));
        // assert late
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_PASSWORD_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchSignIn(tloginParams));
      },
    );

    test(
      'should get the user from the signin use case',
      () async {
        // arrange
        setUpMockSignInInputChecker();
        when(mockSignIn(any)).thenAnswer((_) async => Right(tUser));
        // act
        bloc.add(LaunchSignIn(tloginParams));
        await untilCalled(mockSignIn(any));
        // assert
        verify(mockSignIn(LoginParams(
          emailAddress: tEmailAddress,
          password: tPassword,
        )));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockSignInInputChecker();
        when(mockSignIn(any)).thenAnswer((_) async => Right(tUser));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Loaded(user: tUser),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchSignIn(tloginParams));
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        setUpMockSignInInputChecker();
        when(mockSignIn(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchSignIn(tloginParams));
      },
    );

    test(
      '''should emit [Loading, Error] with a proper 
      message for the error when getting data fails''',
      () async {
        // arrange
        setUpMockSignInInputChecker();
        when(mockSignIn(any)).thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchSignIn(tloginParams));
      },
    );
  });

  group('register', () {
    final tEmailAddress = 'toto@gmail.com';
    final tPassword = '123456';
    final tUserId = '123';
    final tToken = '1234';
    final tPseudo = 'toto';

    final tLoginParams = LoginParams(
      emailAddress: tEmailAddress,
      password: tPassword,
    );

    final tUser = User(
      userId: tUserId,
      emailAddress: tEmailAddress,
      token: tToken,
    );

    void setUpMockRegisterInputChecker() =>
        when(mockInputChecker.registerCheck(tLoginParams))
            .thenReturn(Right(tLoginParams));

    test(
      'should call the InputChecker to validate the LoginParams',
      () async {
        // arrange
        setUpMockRegisterInputChecker();
        // act
        bloc.add(LaunchRegister(tLoginParams));
        await untilCalled(mockInputChecker.registerCheck(any));
        // assert
        verify(mockInputChecker.registerCheck(tLoginParams));
      },
    );

    test(
      'should emit [Error] when the emailAddress is invalid',
      () async {
        // arrange
        when(mockInputChecker.registerCheck(any))
            .thenReturn(Left(InvalidEmailAddressFailure()));
        // assert late
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_EMAIL_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchRegister(tLoginParams));
      },
    );

    test(
      'should emit [Error] when the password is invalid',
      () async {
        // arrange
        when(mockInputChecker.registerCheck(any))
            .thenReturn(Left(InvalidPasswordFailure()));
        // assert late
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_PASSWORD_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchRegister(tLoginParams));
      },
    );

    test(
      'should emit [Error] when the pseudo is invalid',
      () async {
        // arrange
        when(mockInputChecker.registerCheck(any))
            .thenReturn(Left(InvalidPseudoFailure()));
        // assert late
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_PSEUDO_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchRegister(tLoginParams));
      },
    );

    test(
      'should get the user from the Register use case',
      () async {
        // arrange
        setUpMockRegisterInputChecker();
        when(mockRegister(any)).thenAnswer((_) async => Right(tUser));
        // act
        bloc.add(LaunchRegister(tLoginParams));
        await untilCalled(mockRegister(any));
        // assert
        verify(mockRegister(LoginParams(
          emailAddress: tEmailAddress,
          password: tPassword,
        )));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockRegisterInputChecker();
        when(mockRegister(any)).thenAnswer((_) async => Right(tUser));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Loaded(user: tUser),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchRegister(tLoginParams));
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        setUpMockRegisterInputChecker();
        when(mockRegister(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchRegister(tLoginParams));
      },
    );

    test(
      '''should emit [Loading, Error] with a proper 
      message for the error when getting data fails''',
      () async {
        // arrange
        setUpMockRegisterInputChecker();
        when(mockRegister(any)).thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(LaunchRegister(tLoginParams));
      },
    );
  });
}
