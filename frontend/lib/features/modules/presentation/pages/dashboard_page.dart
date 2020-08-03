import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cult_connect/features/modules/data/models/module_model.dart';
import 'package:cult_connect/features/modules/domain/entities/sensor.dart';
import 'package:cult_connect/core/error/exception.dart';
import 'package:cult_connect/features/modules/domain/entities/module.dart';

// import 'package:cult_connect/core/error/exception.dart';
// import 'package:cult_connect/features/login/data/models/user_model.dart';
// import 'package:cult_connect/features/modules/data/models/module_model.dart';
// import 'package:cult_connect/features/modules/domain/entities/module.dart';
// import 'package:cult_connect/features/modules/domain/entities/sensor.dart';

import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../bloc/bloc.dart';

class DashboardPage extends StatelessWidget {
  dynamic data;

  DashboardPage({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Homepage'),
        ),
        drawer: Drawer(
          child: ListView.builder(
              itemCount: globalUser.modules.length,
              itemBuilder: (context, index) {
                return new ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      new Text(globalUser.modules[index].name +
                          " - " +
                          globalUser.modules[index].place),
                      IconButton(
                        onPressed: () {
                        },
                        icon: Icon(Icons.settings),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  children: <Widget>[
                    new Column(
                      children: _buildExpandableContent(
                          globalUser.modules[index], context),
                    )
                  ],
                );
              }),
        ),
        body: BlocProvider(
          create: (context) => sl<ModuleBloc>(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: BlocConsumer<ModuleBloc, ModuleState>(
              listener: (context, state) {
                if (state is Empty) {
                  print('Empty');
                }
                if (state is Loaded) print('Loaded');
                if (state is Error) print('errro');
              },
              builder: (context, state) {
                return ListView(
                  children: [
                    BlocBuilder<ModuleBloc, ModuleState>(
                      builder: (context, state) {
                        if (state == null) {
                          print(globalUser);
                          if (globalUser.favouriteSensors != null) {
                            List<Container> modulesList = new List<Container>();
                            for (String id in globalUser.favouriteSensors) {
                              for (ModuleModel module in globalUser.modules) {
                                if (module.sensors[id] != null) {
                                  Sensor sensor = module.sensors[id];
                                  modulesList.add(
                                    Container(
                                      child: Card(
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Column(children: [
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  sensor.name +
                                                      " \n(${module.place})",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.favorite),
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                mapDataTypeToIcon(
                                                    sensor.dataType),
                                                Text(
                                                  sensor.data[0].value
                                                          .toString() +
                                                      sensor.unit,
                                                  style:
                                                      TextStyle(fontSize: 40),
                                                ),
                                              ],
                                            ),
                                            FlatButton(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              onPressed: () {},
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Text('details'),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    // color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            return GridView.count(
                              primary: false,
                              childAspectRatio: (50 / 50),
                              // scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              // Create a grid with 2 columns. If you change the scrollDirection to
                              // horizontal, this produces 2 rows.
                              crossAxisCount: 2,
                              // Generate 100 widgets that display their index in the List.
                              children: modulesList,
                            );
                          } else {
                            print(state);
                            return Text('you got favourites');
                          }
                        }
                        if (state is Empty) {
                          return Text('ookok');
                        } else if (state is Loading)
                          return Text('loading');
                        else if (state is Loaded)
                          return Text('Loading');
                        else
                          return Text('kkkoo');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Text capitalModuleTitle(String moduleTitle) {
    return Text(
      moduleTitle.toUpperCase(),
      style: TextStyle(
        fontSize: 30,
      ),
    );
  }
}

_buildExpandableContent(Module module, BuildContext context) {
  List<Widget> columnContent = [];

  module.sensors.forEach((id, sensor) {
    columnContent.add(
      new ListTile(
          title: Text(
            sensor.name + " (" + sensor.dataType + ")",
            style: new TextStyle(fontSize: 18.0, color: Colors.lightBlue),
          ),
          onTap: () {}),
    );
  });

  return columnContent;
}

Icon mapDataTypeToIcon(String dataType) {
  switch (dataType) {
    case 'temperature':
      return Icon(
        MdiIcons.thermometer,
        size: 60,
        color: Colors.grey[700],
      );
    case 'humidity':
      return Icon(
        MdiIcons.waterPercent,
        size: 60,
        color: Colors.grey[700],
      );
    default:
      throw DataTypeException();
  }
}
