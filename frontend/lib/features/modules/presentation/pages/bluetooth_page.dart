import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'bluetooth_find_devices_page.dart';
import 'bluetooth_off_page.dart';

class BluetoothPage extends StatelessWidget {
  dynamic data;

  BluetoothPage({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              FlutterBlue.instance.startScan(timeout: Duration(seconds: 3));
              return BluetoothFindDevicesPage();
            }
            return BluetoothOffPage(state: state);
          }),
    );
  }
}
