import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../../../../main.dart';
import '../widgets/bluetooth_scan_result_tile.dart';

class BluetoothFindDevicesPage extends StatelessWidget {
  dynamic data;

  BluetoothFindDevicesPage({
    Key key,
    this.data,
  }) : super(key: key);

  Text _addingPhrase() {
    if (globalUser.modules.length == 0) {
      return Text(
        'You are almost there!\nAdd your first module!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      'Let\'s add a new module!',
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // await device.disconnect();
        FlutterBlue.instance.stopScan();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      iconSize: 45,
                      icon: Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        // await device.disconnect();
                        FlutterBlue.instance.stopScan();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/tuto_module.png',
                  scale: 3.7,
                ),
                SizedBox(height: 20),
                _addingPhrase(),
                SizedBox(height: 20),
                StreamBuilder<List<ScanResult>>(
                    stream: FlutterBlue.instance.scanResults,
                    initialData: [],
                    builder: (c, snapshot) {
                      bool isEmpty = true;
                      for (ScanResult result in snapshot.data) {
                        if (result.device.name.split('_')[0] == 'M') {
                          isEmpty = false;
                          break;
                        }
                      }
                      if (isEmpty) {
                        return Text(
                          '(Make sure your module is ON)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                      return Column(
                        children: snapshot.data.map((r) {
                          if (r.device.name.split('_')[0] != 'M')
                            return Container();
                          return ScanResultTile(
                            result: r,
                            onTap: () async {
                              await r.device.connect();
                              await r.device.discoverServices();
                              Navigator.of(context).pushNamed(
                                  '/bluetoothDevicePage',
                                  arguments: r.device);
                            },
                          );
                        }).toList(),
                      );
                    }),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                backgroundColor: Colors.red[400],
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.refresh),
                  onPressed: () => FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}
