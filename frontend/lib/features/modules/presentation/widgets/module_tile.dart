import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../main.dart';
import '../../domain/entities/module.dart';
import '../../domain/entities/sensor.dart';
import '../bloc/bloc.dart';
import '../pages/dashboard_pages.dart';
import 'module_settings_form.dart';
import 'sensor_tile.dart';

List<bool> showModulesSettingsArray = List();

class ModuleTile extends StatelessWidget {
  Module module;
  final bool showOnlyFavourites;
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newPlaceController = TextEditingController();

  int moduleIndex;

  ModuleTile({
    Key key,
    @required this.showOnlyFavourites,
    @required this.moduleIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    module = globalUser.modules[moduleIndex];
    if (showOnlyFavourites && containsAtLeastOneFavouriteSensor(module) ||
        !showOnlyFavourites) {
      return BlocConsumer<ModuleBloc, ModuleState>(
        listener: (context, state) {
          if (state is Loaded && showModulesSettingsArray[moduleIndex]) {
            showModulesSettingsArray[moduleIndex] =
                !showModulesSettingsArray[moduleIndex];
          }
        },
        builder: (context, state) {
          return ExpansionTile(
              initiallyExpanded: showOnlyFavourites,
              title: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      capitalModuleTitle(module.name),
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            showModulesSettingsArray[moduleIndex] =
                                !showModulesSettingsArray[moduleIndex];
                            dispatchShowModuleSettings(
                                context, showModulesSettingsArray[moduleIndex]);
                          })
                    ],
                  ),
                  BlocBuilder<ModuleBloc, ModuleState>(
                    builder: (context, state) {
                      print(_newNameController.text);
                      return showModulesSettingsArray[moduleIndex]
                          ? ModuleSettingsForm(
                              newNameController: _newNameController,
                              newPlaceController: _newPlaceController,
                              module: module,
                              moduleIndex: moduleIndex,
                            )
                          : Container();
                    },
                  ),
                ],
              ),
              children: [
                new ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: module.sensors.length,
                    itemBuilder: (context, int indexSensors) {
                      String key = module.sensors.keys.elementAt(indexSensors);
                      Sensor sensor = module.sensors[key];
                      if ((showOnlyFavourites && sensor.isFavourite) ||
                          !showOnlyFavourites) {
                        return SensorTile(
                            sensor: sensor,
                            module: module,
                            moduleIndex: moduleIndex);
                      }
                      return Container();
                    }),
              ]);
        },
      );
    } else {
      return Container();
    }
  }
}
