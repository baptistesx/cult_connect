import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../login/presentation/widgets/loading_widget.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../bloc/bloc.dart';

class WifiConfigurationForm extends StatelessWidget {
  final routerSsidController = TextEditingController();
  final routerPasswordController = TextEditingController();
  final _signupFormKey = GlobalKey<FormState>();

  WifiParams wifiParams = WifiParams(routerSsid: "", routerPassword: "");

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is Error) {
          final snackBar = SnackBar(
            content: Row(children: [
              Icon(Icons.warning),
              SizedBox(width: 10),
              Text(state.message),
            ]),
            backgroundColor: Colors.red,
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else if (state is Loaded) {
          Navigator.of(context).pushNamed(
            '/addFirstModulePage',
            arguments: null,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _signupFormKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: TextFormField(
                  controller: routerSsidController,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red[400],
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_important),
                    hintText: 'SSID',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    wifiParams.routerSsid = value;
                  },
                  validator: (String routerSsid) {
                    print(routerSsid.length);
                    print(routerSsid.isEmpty);
                    if (routerSsid.isEmpty)
                      return 'Please fill in the router ssid';
                    return null;
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: TextFormField(
                  controller: routerPasswordController,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red[400],
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    wifiParams.routerPassword = value;
                  },
                  validator: (String routerPassword) {
                    print(routerPassword.length);
                    print(routerPassword.isEmpty);
                    if (routerPassword.isEmpty)
                      return 'Please fill in the password';
                    return null;
                  },
                ),
              ),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  if (state is Loading) {
                    return Row(children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                            ),
                            LoadingWidget(color: Colors.white),
                          ],
                        ),
                      ),
                      IconButton(
                        iconSize: 60,
                        alignment: Alignment(-10.0, -10.0),
                        icon: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          // size: 60,
                        ),
                        onPressed: () {
                          dispatchWifiConfiguration(context);
                        },
                      ),
                    ]);
                  } else {
                    return Row(children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                      ),
                      IconButton(
                        iconSize: 60,
                        alignment: Alignment(-10.0, -10.0),
                        icon: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          // size: 60,
                        ),
                        onPressed: () {
                          if (_signupFormKey.currentState.validate()) {
                            dispatchWifiConfiguration(context);
                          }
                        },
                      ),
                    ]);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void dispatchWifiConfiguration(BuildContext context) {
    BlocProvider.of<LoginBloc>(context)
        .add(LaunchWifiConfiguration(wifiParams));
  }
}
