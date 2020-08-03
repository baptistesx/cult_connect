import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../widgets/add_module_form.dart';

class AddFirstModulePage extends StatelessWidget {
  dynamic data;

  AddFirstModulePage({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: BlocProvider(
        create: (context) => sl<ModuleBloc>(),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 25),
                Image.asset(
                  'assets/images/tuto_module.png',
                  scale: 3.7,
                ),
                SizedBox(height: 20),
                Text(
                  'You are almost there!\nAdd your first module!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                AddModuleForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
