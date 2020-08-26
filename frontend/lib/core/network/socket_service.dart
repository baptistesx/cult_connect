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
      socket.emit('identification', 'USER_123');
    });

    socket.on("disconnect", (_) => print('Disconnected'));

    socket.on("appNewData", (data) {
      for (int i = 0; i < globalUser.modules.length; i++) {
        if (data['moduleId'] == globalUser.modules[i].moduleId) {
          globalUser.modules[i].sensors[data['sensorId']].data =
              data['data'] != null
                  ? (data['data'] as List)
                      .map((data) => DataModel.fromJson(data))
                      .toList()
                  : new List();
          dispatchUpdateList(this.socketContext);
          break;
        }
      }
    });
  }

  changeContext(BuildContext context) {
    this.socketContext = context;
  }
}
