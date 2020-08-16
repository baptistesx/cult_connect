import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/usecases/sign_in.dart';
import '../bloc/bloc.dart';
import '../widgets/forgot_password_second_form.dart';

class ForgotPasswordSecondPage extends StatelessWidget {
  LoginParams loginParams;
  String verificationCode;

  ForgotPasswordSecondPage({Key key, dynamic data})
      : loginParams = data["loginParams"],
        verificationCode = data["verificationCode"],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: BlocProvider(
          create: (context) => sl<LoginBloc>(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/logo.png',
                    scale: 1.4,
                  ),
                  Image.asset(
                    'assets/images/logo_nom_fonce.png',
                    scale: 1.8,
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Enter the verification code to update your password...",
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25),
                  ForgotPasswordSecondForm(loginParams, verificationCode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
