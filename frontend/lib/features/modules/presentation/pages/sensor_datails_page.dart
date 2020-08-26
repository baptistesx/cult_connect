import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/socket_service.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../../../login/presentation/widgets/loading_widget.dart';
import '../../domain/entities/data.dart';
import '../../domain/entities/sensor.dart';
import '../bloc/bloc.dart';
import 'dashboard_pages.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class SensorDetailsPage extends StatelessWidget {
  dynamic data;
  Sensor sensor;
  bool showSettings = false;

  SensorDetailsPage({
    Key key,
    this.data,
  })  : sensor =
            globalUser.modules[data["moduleIndex"]].sensors[data["sensorId"]],
        super(key: key);

  @override
  Widget build(context) {
    final TextEditingController _newNameController = TextEditingController();

    final _updateSensorFormKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        dispatchUpdateList(context);
        Navigator.pop(context);
        return true;
      },
      child: BlocConsumer<ModuleBloc, ModuleState>(
        listener: (context, state) {
          if (state is Loaded && showSettings) {
            showSettings = !showSettings;
            dispatchShowSensorSettings(context);
          }
        },
        builder: (context, state) {
          sl<SocketService>().changeContext(context);
          
          return BlocBuilder<ModuleBloc, ModuleState>(
              builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                  title: Row(
                    children: <Widget>[
                      mapDataTypeToIcon(sensor.dataType, 35, Colors.white),
                      BlocBuilder<ModuleBloc, ModuleState>(
                        builder: (context, state) {
                          sensor.name = globalUser.modules[data["moduleIndex"]]
                              .sensors[data["sensorId"]].name;
                          return Text(sensor.name);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          showSettings = !showSettings;
                          dispatchShowSensorSettings(context);
                        }),
                  ]),
              body: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: BlocBuilder<ModuleBloc, ModuleState>(
                      builder: (context, state) {
                        return showSettings
                            ? Form(
                                key: _updateSensorFormKey,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          child: TextFormField(
                                            controller: _newNameController,
                                            decoration: const InputDecoration(
                                              // icon: Icon(Icons.person),
                                              hintText: 'New name',
                                              // labelText: 'Email *',
                                            ),
                                            validator: (String value) {
                                              if (value.length < 3)
                                                return 'Please, enter a longer name';
                                              if (value == sensor.name)
                                                return 'The name is the same as previoulsy';
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                              onPressed: () async {
                                                if (_updateSensorFormKey
                                                    .currentState
                                                    .validate()) {
                                                  var newName =
                                                      _newNameController.text;
                                                  dispatchUpdateSensorSettings(
                                                      context, newName);
                                                  // var response =
                                                  //     await updateSensor(sensor.sensorId, newName);
                                                  // if (response == "ok") {
                                                  //   sensor.name = newName;
                                                  // }

                                                  // displayDialog(context, "Result", response, 2);
                                                }
                                              },
                                              child: Text('Save')),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                              onPressed: () {
                                                showSettings = !showSettings;

                                                dispatchShowSensorSettings(
                                                    context);
                                                // Navigator.pop(context);
                                              },
                                              child: Text('Cancel')),
                                        ),
                                      ],
                                    ),
                                    BlocBuilder<ModuleBloc, ModuleState>(
                                      builder: (context, state) {
                                        if (state is Loading) {
                                          return LoadingWidget(
                                              color: Theme.of(context)
                                                  .accentColor);
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Container();
                      },
                    ),
                  ),
                  BlocBuilder<ModuleBloc, ModuleState>(
                      builder: (context, state) {
                    print("ddddd");
                    // if (state is Loaded) return Text("essai");
                    // print("before: $sensor");
                    // sensor = globalUser
                    //     .modules[data["moduleIndex"]].sensors[data["sensorId"]];
                    // print("after: $sensor");
                    return getChartWidget();
                    // return chartWidget;
                  }),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget getChartWidget() {
    print(sensor);
    var series = [
      new charts.Series(
        id: 'Clicks',
        domainFn: (Data clickData, _) => clickData.date,
        measureFn: (Data clickData, _) => clickData.value,
        // colorFn: (Value clickData, _) => clickData.color,
        data: sensor.data,
      ),
    ];
    var chart = new charts.TimeSeriesChart(
      series,
      animate: true,
      behaviors: [
        new charts.ChartTitle(
            capitalize(sensor.dataType) + " (" + sensor.unit + ")",
            // subTitle: 'Top sub-title text',
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,
            // Set a larger inner padding than the default (10) to avoid
            // rendering the text too close to the top measure axis tick label.
            // The top tick label may extend upwards into the top margin region
            // if it is located at the top of the draw area.
            innerPadding: 18),
        // new charts.ChartTitle('Bottom title text',
        //     behaviorPosition: charts.BehaviorPosition.bottom,
        //     titleOutsideJustification:
        //         charts.OutsideJustification.middleDrawArea),
      ],
    );
    var chartWidget = new Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 200.0,
        child: chart,
      ),
    );
    return chartWidget;
  }

  void dispatchShowSensorSettings(BuildContext context) {
    BlocProvider.of<ModuleBloc>(context)
        .add(LaunchShowSensorSettings(showSettings));
  }

  void dispatchUpdateSensorSettings(BuildContext context, String newName) {
    BlocProvider.of<ModuleBloc>(context).add(LaunchUpdateSensorSettings(
        UpdateSensorParams(newName: newName, sensorId: sensor.sensorId)));
  }
}

class UpdateSensorParams {
  String sensorId;
  String newName;

  UpdateSensorParams({@required this.sensorId, @required this.newName});
}