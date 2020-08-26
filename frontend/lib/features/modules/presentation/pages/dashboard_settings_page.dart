import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../login/presentation/bloc/bloc.dart';
import '../../../login/presentation/bloc/login_bloc.dart';
import '../bloc/bloc.dart';
import 'dashboard_pages.dart';

class DashboardSettingsPage extends StatelessWidget {
  dynamic data;

  DashboardSettingsPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: BlocConsumer<ModuleBloc, ModuleState>(
                listener: (context, state) {},
                builder: (context, istate) {
                  return BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginEmpty) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> route) => false);
                      }
                    },
                    builder: (context, state) {
                      return FlatButton(
                        onPressed: () {
                          dispatchSignOut(context);
                        },
                        child: Text("Log out"),
                      );
                    },
                  );
                })));
  }
}
