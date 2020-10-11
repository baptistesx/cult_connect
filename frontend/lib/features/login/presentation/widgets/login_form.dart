import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../main.dart';
import '../../domain/usecases/sign_in.dart';
import '../bloc/bloc.dart';
import 'loading_widget.dart';

class LoginForm extends StatelessWidget {
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  LoginParams loginParams = LoginParams(emailAddress: "", password: "");
  final _signupFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _signupFormKey,
        child: BlocConsumer<LoginBloc, LoginState>(
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
        }, builder: (context, loginState) {
          if (loginState == null && jwt != "") dispatchAutoSignIn(context);
          if (loginState is JWTCheckLoading ||
              (loginState is LoginLoaded && jwt != "")) {
            return Center(
                child: LoadingWidget(color: Theme.of(context).accentColor));
          }
          return Column(
            children: <Widget>[
              TextFormField(
                controller: emailAddressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  labelText: 'Email',
                ),
                onChanged: (value) {
                  loginParams.emailAddress = value;
                },
                onFieldSubmitted: (value) {
                  if (_signupFormKey.currentState.validate()) {
                    dispatchSignIn(context);
                  }
                },
                validator: (String emailAddress) {
                  if (emailAddress.isEmpty) return EMPTY_EMAIL_FAILURE_MESSAGE;
                  if (!RegExp(EMAIL_REGEX).hasMatch(emailAddress))
                    return INVALID_EMAIL_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Password',
                  labelText: 'Password',
                ),
                onChanged: (value) {
                  loginParams.password = value;
                },
                onFieldSubmitted: (value) {
                  if (_signupFormKey.currentState.validate()) {
                    dispatchSignIn(context);
                  }
                },
                validator: (String password) {
                  if (password.isEmpty) return EMPTY_PASSWORD_FAILURE_MESSAGE;
                  if (password.length <= 6)
                    return INVALID_PASSWORD_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 10),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/forgotPasswordFirstPage',
                    arguments: null,
                  );
                },
                child: Text(
                  'Forgot your password?',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Let\'s go!'),
                      color: Theme.of(context).accentColor,
                      textTheme: ButtonTextTheme.primary,
                      textColor: const Color(0xFFFFFFFF),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_signupFormKey.currentState.validate()) {
                          dispatchSignIn(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              Text(
                '- or -',
                style: Theme.of(context).textTheme.headline4,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Register'),
                      color: Colors.grey[200],
                      textTheme: ButtonTextTheme.primary,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_signupFormKey.currentState.validate()) {
                          dispatchRegister(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return LoadingWidget(color: Theme.of(context).accentColor);
                  } else {
                    return Container(
                      width: 0.0,
                      height: 0.0,
                    );
                  }
                },
              ),
            ],
          );
        }));
  }

  void dispatchAutoSignIn(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(LaunchAutoSignIn());
  }

  void dispatchSignIn(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(LaunchSignIn(loginParams));
  }

  void dispatchRegister(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(LaunchRegister(loginParams));
  }
}
