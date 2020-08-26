import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../main.dart';
import '../../domain/usecases/sign_in.dart';
import '../bloc/bloc.dart';
import 'loading_widget.dart';

class ForgotPasswordSecondForm extends StatelessWidget {
  String enteredCode = "";
  final enteredCodeController = TextEditingController();
  final _signupFormKey = GlobalKey<FormState>();
  LoginParams loginParams;
  String verificationCode;

  ForgotPasswordSecondForm(
      @required this.loginParams, @required this.verificationCode)
      : super();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          final snackBar = SnackBar(
            duration: const Duration(seconds: 3),
            content: Row(children: [
              Icon(Icons.warning),
              SizedBox(width: 10),
              Flexible(
                  child: Text(
                state.message,
              )),
            ]),
            backgroundColor: Colors.red[400],
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else if (state is LoginLoaded) {
          if (globalUser.modules.isEmpty) {
            Navigator.of(context).pushNamed(
              '/tutorialPages',
              arguments: null,
            );
          } else {
            Navigator.of(context).pushNamed(
              '/dashboardPage',
              arguments: null,
            );
          }
        } else if (state is VerificationCodeLoaded) {
          verificationCode = state.verificationCode;
        }
      },
      builder: (context, state) {
        return Form(
          key: _signupFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: enteredCodeController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(MdiIcons.numeric),
                  hintText: 'Verification code',
                  labelText: 'Verification code',
                ),
                onChanged: (code) {
                  enteredCode = code;
                },
                validator: (String code) {
                  if (code.isEmpty)
                    return EMPTY_VERIFICATION_CODE_FAILURE_MESSAGE;
                  if (code.length != 3)
                    return INVALID_VERIFICATION_CODE_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Let\'s go!'),
                      color: Theme.of(context).accentColor,
                      textTheme: ButtonTextTheme.primary,
                      textColor: const Color(0xFFFFFFFF),
                      onPressed: () {
                        if (_signupFormKey.currentState.validate()) {
                          dispatchUpdatePassword(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'No code received?',
                style: Theme.of(context).textTheme.headline4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: RaisedButton(
                      child: Text('Send me a code again...'),
                      color: Colors.grey[200],
                      textTheme: ButtonTextTheme.primary,
                      onPressed: () async {
                        await dispatchSendVerificationCode(context);
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
                    return Container();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void dispatchUpdatePassword(BuildContext context) {
    BlocProvider.of<LoginBloc>(context)
        .add(LaunchUpdatePassword(verificationCode, enteredCode, loginParams));
  }

  void dispatchSendVerificationCode(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(LaunchSendVerificationCode(
      loginParams.emailAddress,
      loginParams.password,
    ));
  }
}
