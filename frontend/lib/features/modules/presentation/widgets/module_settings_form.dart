import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../login/presentation/widgets/widgets.dart';
import '../../domain/entities/module.dart';
import '../bloc/bloc.dart';
import '../pages/dashboard_pages.dart';
import 'module_tile.dart';

class ModuleSettingsForm extends StatelessWidget {
  int moduleIndex;
  final _updateModuleFormKey = GlobalKey<FormState>();
  Module module;
  final TextEditingController newNameController;
  final TextEditingController newPlaceController;

  ModuleSettingsForm({
    Key key,
    this.module,
    this.moduleIndex,
    this.newNameController,
    this.newPlaceController,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return showModulesSettingsArray[moduleIndex]
        ? Form(
            key: _updateModuleFormKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: newNameController,
                  decoration: const InputDecoration(
                    hintText: 'New name',
                  ),
                  validator: (String value) {
                    if (value.length < 3) return 'Please, enter a longer name';
                    if (value == module.name)
                      return 'The name is the same as previoulsy';
                  },
                ),
                TextFormField(
                  controller: newPlaceController,
                  decoration: const InputDecoration(
                    hintText: 'New place',
                  ),
                  validator: (String value) {
                    if (value.length < 3)
                      return 'Please, enter a longer place name';
                    if (value == module.name)
                      return 'The name is the same as previoulsy';
                  },
                ),
                Row(children: [
                  BlocBuilder<ModuleBloc, ModuleState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                            onPressed: () async {
                              if (_updateModuleFormKey.currentState
                                  .validate()) {
                                    print(newNameController.text);
                                var newName = newNameController.text;
                                var newPlace = newPlaceController.text;
                                dispatchUpdateModuleSettings(
                                  context,
                                  module.moduleId,
                                  newName,
                                  newPlace,
                                );
                              }
                            },
                            child: Text('Save')),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                        onPressed: () {
                          showModulesSettingsArray[moduleIndex] =
                              !showModulesSettingsArray[moduleIndex];

                          dispatchShowModuleSettings(
                              context, showModulesSettingsArray[moduleIndex]);
                        },
                        child: Text('Cancel')),
                  ),
                ]),
                BlocBuilder<ModuleBloc, ModuleState>(
                  builder: (context, state) {
                    if (state is LoadingWhileUpdatingModule) {
                      return LoadingWidget(
                          color: Theme.of(context).accentColor);
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          )
        : Container();
  }
}
