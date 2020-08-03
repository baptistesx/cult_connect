import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cult_connect/features/login/domain/usecases/sign_in.dart';
// import 'package:cult_connect/features/login/domain/usecases/sign_in.dart';

import '../../../../core/constants/constants.dart';
import '../bloc/bloc.dart';
import 'loading_widget.dart';

class ForgotPasswordFirstForm extends StatelessWidget {
  final emailAddressController = TextEditingController();
  final newPasswordController = TextEditingController();
  String emailAddress = "";
  String newPassword = "";
  final _signupFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is Error) {
          final snackBar = SnackBar(
            duration: const Duration(seconds: 1),
            content: Row(children: [
              Icon(Icons.warning),
              SizedBox(width: 10),
              Text(state.message),
            ]),
            backgroundColor: Colors.red[400],
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else if (state is VerificationCodeLoaded) {
          Navigator.of(context).pushNamed(
            '/forgotPasswordSecondPage',
            arguments:
                LoginParams(emailAddress: emailAddress, password: newPassword),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _signupFormKey,
          child: Column(
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
                  emailAddress = value;
                },
                validator: (String emailAddress) {
                  if (emailAddress.isEmpty) return EMPTY_EMAIL_FAILURE_MESSAGE;
                  if (!RegExp(EMAIL_REGEX).hasMatch(emailAddress))
                    return INVALID_EMAIL_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'New password',
                  labelText: 'New password',
                ),
                onChanged: (value) {
                  newPassword = value;
                },
                validator: (String password) {
                  if (password.isEmpty) return EMPTY_PASSWORD_FAILURE_MESSAGE;
                  if (password.length <= 6)
                    return INVALID_PASSWORD_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Send me a verification code'),
                      color: Colors.grey[200],
                      textTheme: ButtonTextTheme.primary,
                      onPressed: () {
                        if (_signupFormKey.currentState.validate()) {
                          dispatchSendVerificationCode(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  if (state is Loading) {
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

  void dispatchSendVerificationCode(BuildContext context) {
    BlocProvider.of<LoginBloc>(context)
        .add(LaunchSendVerificationCode(emailAddress, newPassword));
  }
}
