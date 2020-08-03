import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cult_connect/features/login/presentation/util/login_input_checker.dart';
import 'package:cult_connect/features/login/domain/usecases/register.dart';
import 'package:cult_connect/features/login/domain/usecases/sign_in.dart';

void main() {
  InputChecker inputChecker;

  setUp(() {
    inputChecker = InputChecker();
  });

  group('Input checking', () {
    group('signIn checking', () {
      test(
        'should return a InvalidPasswordFailure',
        () async {
          // arrange
          final tEmailAddress = 'toto@gmail.com';
          final tPassword = 'toto';
          final tloginParams = LoginParams(
            emailAddress: tEmailAddress,
            password: tPassword,
          );
          // act
          final result = inputChecker.signInCheck(tloginParams);
          // assert
          expect(result, equals(Left(InvalidPasswordFailure())));
        },
      );

      test(
        'should return a InvalidEmailAddressFailure',
        () async {
          // arrange
          LoginParams tloginParams;
          final tPassword = 'totototo';

          // act
          tloginParams = LoginParams(
            emailAddress: 'totogmail.com',
            password: tPassword,
          );
          final result1 = inputChecker.signInCheck(tloginParams);
          tloginParams = LoginParams(
            emailAddress: 'toto@gmailcom',
            password: tPassword,
          );
          final result2 = inputChecker.signInCheck(tloginParams);
          tloginParams = LoginParams(
            emailAddress: 'toto@gmail.',
            password: tPassword,
          );
          final result3 = inputChecker.signInCheck(tloginParams);
          tloginParams = LoginParams(
            emailAddress: 'toto.gmail@',
            password: tPassword,
          );
          final result4 = inputChecker.signInCheck(tloginParams);

          // assert
          expect(result1, Left(InvalidEmailAddressFailure()));
          expect(result2, Left(InvalidEmailAddressFailure()));
          expect(result3, Left(InvalidEmailAddressFailure()));
          expect(result4, Left(InvalidEmailAddressFailure()));
        },
      );
    });

    group('register checking', () {
      test(
        'should return a InvalidPasswordFailure',
        () async {
          // arrange
          final tEmailAddress = 'toto@gmail.com';
          final tPassword = 'toto';
          final tPseudo = 'toto';
          final tLoginParams = LoginParams(
            emailAddress: tEmailAddress,
            password: tPassword,
          );
          // act
          final result = inputChecker.registerCheck(tLoginParams);
          // assert
          expect(result, Left(InvalidPasswordFailure()));
        },
      );

      test(
        'should return a InvalidEmailAddressFailure',
        () async {
          // arrange
          LoginParams tLoginParams;
          final tPassword = 'totototo';
          final tPseudo = 'toto';

          // act
          tLoginParams = LoginParams(
            emailAddress: 'totogmail.com',
            password: tPassword,
          );
          final result1 = inputChecker.registerCheck(tLoginParams);
          tLoginParams = LoginParams(
            emailAddress: 'toto@gmailcom',
            password: tPassword,
          );
          final result2 = inputChecker.registerCheck(tLoginParams);
          tLoginParams = LoginParams(
            emailAddress: 'toto@gmail.',
            password: tPassword,
          );
          final result3 = inputChecker.registerCheck(tLoginParams);
          tLoginParams = LoginParams(
            emailAddress: 'toto.gmail@',
            password: tPassword,
          );
          final result4 = inputChecker.registerCheck(tLoginParams);

          // assert
          expect(result1, Left(InvalidEmailAddressFailure()));
          expect(result2, Left(InvalidEmailAddressFailure()));
          expect(result3, Left(InvalidEmailAddressFailure()));
          expect(result4, Left(InvalidEmailAddressFailure()));
        },
      );

      test(
        'should return a InvalidPseudoFailure',
        () async {
          // arrange
          final tEmailAddress = 'toto@gmail.com';
          final tPassword = 'totototo';
          final tPseudo = 'toto';
          final tLoginParams = LoginParams(
            emailAddress: tEmailAddress,
            password: tPassword,
          );
          // act
          final result = inputChecker.registerCheck(tLoginParams);
          // assert
          expect(result, Left(InvalidPseudoFailure()));
        },
      );
    });
  });
}
