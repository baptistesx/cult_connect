import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../../../login/presentation/bloc/bloc.dart';
import '../../domain/entities/module.dart';
import '../bloc/bloc.dart';
import '../widgets/module_tile.dart';
import 'dashboard_first_page.dart';
import 'dashboard_second_page.dart';
import 'dashboard_settings_page.dart';

class DashboardPages extends StatefulWidget {
  dynamic data;

  DashboardPages({Key key, this.data}) : super(key: key);

  @override
  _DashboardPagesState createState() => _DashboardPagesState();
}

class _DashboardPagesState extends State<DashboardPages> {
  PageController _controller = PageController();

  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool clickedCentreFAB =
      false; //boolean used to handle container animation which expands from the FAB
  int selectedIndex =
      0; //to handle which item is currently selected in the bottom app bar

  //call this method on click of each bottom app bar item to update the screen
  void updateTabSelection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(globalUser);
    initShowModulesSettingsArray();

    final List<Widget> _pages = <Widget>[
      DashboardFirstPage(),
      DashboardSecondPage(),
      DashboardSettingsPage(),
    ];
    return BlocConsumer<ModuleBloc, ModuleState>(
      listener: (context, state) {
        sl<SocketService>().changeContext(context);
      },
      builder: (context, state) {
        sl<SocketService>().createSocketConnection(context);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: PageView.builder(
                physics: new AlwaysScrollableScrollPhysics(),
                controller: _controller,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _pages.length) return null;
                  return _pages[index % _pages.length];
                },
                onPageChanged: (index) {
                  updateTabSelection(index);
                },
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation
                .centerDocked, //specify the location of the FAB
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/bluetoothPage',
                  arguments: null,
                );
              },
              tooltip: "Centre FAB",
              child: Container(
                margin: EdgeInsets.all(15.0),
                child: Icon(Icons.add),
              ),
              elevation: 4.0,
              backgroundColor: Color(0xFFc5dace),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                margin: EdgeInsets.only(left: 12.0, right: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      //update the bottom app bar view each time an item is clicked
                      onPressed: () {
                        _controller.animateToPage(
                          0,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                        updateTabSelection(0);
                      },
                      iconSize: 27.0,
                      icon: Icon(MdiIcons.star,
                          //darken the icon if it is selected or else give it a different color
                          color: selectedIndex == 0
                              ? const Color(0xFF112a26)
                              : Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        _controller.animateToPage(
                          1,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                        updateTabSelection(1);
                      },
                      iconSize: 27.0,
                      icon: Icon(MdiIcons.hexagonMultipleOutline,
                          color: selectedIndex == 1
                              ? const Color(0xFF112a26)
                              : Colors.white),
                    ),
                    //to leave space in between the bottom app bar items and below the FAB
                    SizedBox(
                      width: 100.0,
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     updateTabSelection(2, "Incoming");
                    //   },
                    //   iconSize: 27.0,
                    //   icon: Icon(
                    //     Icons.call_received,
                    //     color: selectedIndex == 2
                    //         ? const Color(0xFF112a26)
                    //         : Colors.white
                    //   ),
                    // ),
                    IconButton(
                      onPressed: () {
                        _controller.animateToPage(
                          2,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                        updateTabSelection(2);
                      },
                      iconSize: 27.0,
                      icon: Icon(Icons.settings,
                          color: selectedIndex == 2
                              ? const Color(0xFF112a26)
                              : Colors.white),
                    ),
                  ],
                ),
              ),
              //to add a space between the FAB and BottomAppBar
              shape: CircularNotchedRectangle(),
              //color of the BottomAppBar
              color: const Color(0xFF487463),
            ),
          ),
        );
      },
    );
  }
}

initShowModulesSettingsArray() {
  showModulesSettingsArray = List();
  for (int i = 0; i < globalUser.modules.length; i++) {
    showModulesSettingsArray.add(false);
  }
  print(showModulesSettingsArray);
}

Icon mapDataTypeToIcon(String dataType, double size, Color color) {
  switch (dataType) {
    case 'temperature':
      return Icon(
        MdiIcons.thermometer,
        size: size,
        color: color,
      );
    case 'humidity':
      return Icon(
        MdiIcons.waterPercent,
        size: size,
        color: color,
      );
    case 'luminosity':
      return Icon(
        MdiIcons.weatherSunny,
        size: size,
        color: color,
      );
    default:
      throw DataTypeException();
  }
}

bool containsAtLeastOneFavouriteSensor(Module module) {
  if (module.sensors.toString().contains("isFavourite: true")) return true;
  return false;
}

Text capitalModuleTitle(String moduleTitle) {
  return Text(
    moduleTitle.toUpperCase(),
    style: TextStyle(fontSize: 25),
    textAlign: TextAlign.center,
  );
}

Widget displayModulesList(
  BuildContext context,
  bool showOnlyFavourites,
) {
  if (showOnlyFavourites && globalUser.favouriteSensors.isEmpty)
    return Center(
      child: Text(
        "You don't have any favourite sensor to display.",
        style: TextStyle(
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );

  if (showOnlyFavourites) {
    return ListView.builder(
      itemCount: globalUser.modules.length,
      itemBuilder: (context, int index) {
        return containsAtLeastOneFavouriteSensor(globalUser.modules[index])
            ? ModuleTile(
                showOnlyFavourites: showOnlyFavourites, moduleIndex: index)
            : Container();
      },
    );
  } else {
    return ListView.builder(
        itemCount: globalUser.modules.length,
        itemBuilder: (context, int index) => ModuleTile(
              showOnlyFavourites: showOnlyFavourites,
              moduleIndex: index,
            ));
  }
}

void dispatchRemoveFavouriteSensorById(BuildContext context, sensorId) {
  BlocProvider.of<ModuleBloc>(context)
      .add(LaunchRemoveFavouriteSensorById(sensorId));
}

void dispatchAddFavouriteSensorById(BuildContext context, sensorId) {
  BlocProvider.of<ModuleBloc>(context)
      .add(LaunchAddFavouriteSensorById(sensorId));
}

void dispatchUpdateList(BuildContext context) {
  BlocProvider.of<ModuleBloc>(context).add(LaunchUpdateList());
}

void dispatchUpdateModuleSettings(
    BuildContext context, String moduleId, String newName, String newPlace) {
  BlocProvider.of<ModuleBloc>(context).add(LaunchUpdateModuleSettings(
      UpdateModuleParams(
          newName: newName, moduleId: moduleId, newPlace: newPlace)));
}

void dispatchShowModuleSettings(BuildContext context, bool showSettings) {
  BlocProvider.of<ModuleBloc>(context)
      .add(LaunchShowModuleSettings(showSettings));
}

void dispatchSignOut(BuildContext context) {
  BlocProvider.of<LoginBloc>(context).add(LaunchSignOut());
}
