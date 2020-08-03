import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../widgets/wifi_configuration_form.dart';

class WifiConfigurationPage extends StatelessWidget {
  dynamic data;

  WifiConfigurationPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: BlocProvider(
          create: (context) => sl<LoginBloc>(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/tuto3.png',
                    scale: 3.7,
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Let\'s begin by entering the internet router identifiers:',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  WifiConfigurationForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
