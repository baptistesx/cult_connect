import 'package:cult_connect/features/modules/domain/entities/module.dart';
import 'package:cult_connect/features/modules/domain/entities/sensor.dart';
import 'package:cult_connect/features/modules/presentation/bloc/bloc.dart';
import 'package:cult_connect/features/modules/presentation/pages/dashboard_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SensorTile extends StatelessWidget {
  final Sensor sensor;
  final Module module;
  final int moduleIndex;

  SensorTile({
    Key key,
    @required this.sensor,
    @required this.module,
    @required this.moduleIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          mapDataTypeToIcon(sensor.dataType, 60, Colors.grey[400]),
        ],
      ),
      title: Row(
        children: <Widget>[
          Text(
            '${sensor.name}: ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '${module.place}',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      subtitle: Text(
        sensor.data[0].value.toString() + sensor.unit,
        style: TextStyle(fontSize: 30),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: sensor.isFavourite
                ? Icon(MdiIcons.star)
                : Icon(MdiIcons.starOutline),
            onPressed: () {
              if (sensor.isFavourite) {
                dispatchRemoveFavouriteSensorById(context, sensor.sensorId);
              } else {
                dispatchAddFavouriteSensorById(context, sensor.sensorId);
              }
            },
          ),
          Icon(Icons.keyboard_arrow_right),
        ],
      ),
      onTap: () async {
        await Navigator.of(context).pushNamed('/sensorDetailsPage', arguments: {
          "blocProvider": BlocProvider.of<ModuleBloc>(context),
          "moduleIndex": moduleIndex,
          "sensorId": sensor.sensorId,
        });
        dispatchUpdateList(context);
      },
    );
  }
}
