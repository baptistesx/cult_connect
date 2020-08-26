import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../main.dart';
import '../../../login/presentation/widgets/widgets.dart';
import '../bloc/bloc.dart';
import 'dashboard_pages.dart';

class DashboardSecondPage extends StatelessWidget {
  bool showOnlyFavourites = false;

  DashboardSecondPage();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: BlocConsumer<ModuleBloc, ModuleState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (globalUser.modules.isEmpty)
                    return Center(
                      child: Text(
                        NO_MODULE_REGISTERED,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  return Column(
                    children: [
                      BlocBuilder<ModuleBloc, ModuleState>(
                          builder: (context, state) {
                        return Expanded(
                            child: displayModulesList(
                                context, showOnlyFavourites));
                      }),
                      BlocBuilder<ModuleBloc, ModuleState>(
                        builder: (context, state) {
                          if (state is Loading) {
                            return Expanded(
                                child: Column(
                              children: <Widget>[
                                LoadingWidget(
                                    color: Theme.of(context).accentColor),
                                Spacer(),
                              ],
                            ));
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  );
                })));
  }
}
