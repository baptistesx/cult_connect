import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../main.dart';
import '../bloc/bloc.dart';
import '../widgets/login_form.dart';
import '../widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  dynamic data;

  LoginPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  void dispatchAutoSignIn(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(LaunchAutoSignIn());
  }
}
