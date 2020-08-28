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
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginError) {
            final snackBar = SnackBar(
              duration: const Duration(seconds: 1),
              content: Row(children: [
                Icon(Icons.warning),
                SizedBox(
                  width: 10,
                ),
                Text(state.message),
              ]),
              backgroundColor: Colors.red[400],
            );
            Scaffold.of(context).showSnackBar(snackBar);
          } else if (state is LoginLoaded) {
            if (globalUser.modules.isEmpty) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/tutorialPages',
                (Route<dynamic> route) => false,
                arguments: null,
              );
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/dashboardPages',
                (Route<dynamic> route) => false,
                arguments: null,
              );
            }
          }
        },
        builder: (context, loginState) {
          if (loginState == null && jwt != "") dispatchAutoSignIn(context);
          if (loginState is JWTCheckLoading ||
              (loginState is LoginLoaded && jwt != "")) {
            return Center(
                child: LoadingWidget(color: Theme.of(context).accentColor));
          }
          return Padding(
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
          );
        },
      ),
    );
  }

  void dispatchAutoSignIn(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(LaunchAutoSignIn());
  }
}
