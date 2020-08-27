import 'dart:convert';

import 'package:cult_connect/features/modules/domain/entities/module.dart';
import 'package:cult_connect/features/modules/domain/entities/sensor.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/modules/data/models/data_model.dart';
import '../../features/modules/presentation/pages/dashboard_pages.dart';
import '../../main.dart';
import 'network_info.dart';

class SocketService {
  IO.Socket socket;
  BuildContext socketContext;

  createSocketConnection(BuildContext context) {
    this.socketContext = context;

    socket = IO.io(SERVER_IP, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on("connect", (_) {
      socket.emit('identification', 'USER_' + jwt);
    });

    socket.on("disconnect", (_) => print('Disconnected'));

    socket.on("appNewData", (dataReceived) {
      var dataDecoded = json.decode(dataReceived);

      print("----------------");
      print("----------------");
      print(dataDecoded['moduleId']);
      print("----------------");
      print(dataDecoded['sensorId']);
      print("----------------");
      print(dataDecoded['data']);
      print("----------------");

      for (int i = 0; i < globalUser.modules.length; i++) {
        Module module = globalUser.modules[i];
        if (module.moduleId == dataDecoded['moduleId']) {
          for (int j = 0; j < module.sensors.length; j++) {
            Sensor sensor = module.sensors[j];
            if (sensor.sensorId == dataDecoded['sensorId']) {
              sensor.data = dataDecoded['data'] != null
              ? (dataDecoded['data'] as List)
                  .map((data) => DataModel.fromJson(data))
                  .toList()
              : new List();
            }
          }
        }
      }

      // globalUser.modules[dataDecoded['moduleIndex']]
      //         .sensors[dataDecoded['sensorIndex']].data =
      //     dataDecoded['data'] != null
      //         ? (dataDecoded['data'] as List)
      //             .map((data) => DataModel.fromJson(data))
      //             .toList()
      //         : new List();
      dispatchUpdateList(this.socketContext);
    });
  }

  changeContext(BuildContext context) {
    this.socketContext = context;
  }
}
