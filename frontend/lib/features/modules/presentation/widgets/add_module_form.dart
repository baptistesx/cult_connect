import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../login/presentation/widgets/loading_widget.dart';
import '../../domain/usecases/add_module.dart';
import '../bloc/bloc.dart';

class AddModuleForm extends StatelessWidget {
  final publicIdController = TextEditingController();
  final privateIdController = TextEditingController();
  final nameController = TextEditingController();
  final placeController = TextEditingController();
  final _signupFormKey = GlobalKey<FormState>();

  AddModuleParams addModuleParams = AddModuleParams(
    token: '123',
    publicId: "",
    privateId: "",
    name: "",
    place: "",
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModuleBloc, ModuleState>(
      listener: (context, state) {
        if (state is Error) {
          final snackBar = SnackBar(
            content: Row(children: [
              Icon(Icons.warning),
              SizedBox(
                width: 10,
              ),
              Text(state.message),
            ]),
            backgroundColor: Colors.red,
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else if (state is Loaded) {
          Navigator.of(context).pushNamed(
            '/dashboardPage',
            arguments: null,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _signupFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: publicIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    color: Colors.red[400],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_important),
                  hintText: 'Public Id',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  addModuleParams.publicId = value;
                },
                validator: (String publicId) {
                  if (publicId.isEmpty) return EMPTY_PUBLIC_ID_FAILURE_MESSAGE;
                  if (publicId.length != 3)
                    return INVALID_PUBLIC_ID_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: privateIdController,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    color: Colors.red[400],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_important),
                  hintText: 'Private Id',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  addModuleParams.privateId = value;
                },
                validator: (String privateId) {
                  if (privateId.isEmpty)
                    return EMPTY_PRIVATE_ID_FAILURE_MESSAGE;
                  if (privateId.length != 3)
                    return INVALID_PRIVATE_ID_FAILURE_MESSAGE;
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                  hintText: 'NickName',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  addModuleParams.name = value;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: placeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                  hintText: 'Place',
                  // labelText: 'Place',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  addModuleParams.place = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      if (_signupFormKey.currentState.validate()) {
                        dispatchAddModule(context);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Go',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 60,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              BlocBuilder<ModuleBloc, ModuleState>(
                builder: (context, state) {
                  if (state is Loading) {
                    return LoadingWidget(
                      color: Colors.white,
                    );
                  } else {
                    return Container(
                      width: 0.0,
                      height: 0.0,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void dispatchAddModule(BuildContext context) {
    BlocProvider.of<ModuleBloc>(context).add(LaunchAddModule(addModuleParams));
  }
}
