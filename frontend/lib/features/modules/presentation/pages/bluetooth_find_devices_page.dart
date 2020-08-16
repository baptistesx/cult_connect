import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../widgets/bluetooth_scan_result_tile.dart';

class BluetoothFindDevicesPage extends StatelessWidget {
  dynamic data;

  BluetoothFindDevicesPage({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 25),
              Image.asset(
                'assets/images/tuto_module.png',
                scale: 3.7,
              ),
              SizedBox(height: 20),
              Text(
                'You are almost there!\nAdd your first module!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              StreamBuilder<List<ScanResult>>(
                  stream: FlutterBlue.instance.scanResults,
                  initialData: [],
                  builder: (c, snapshot) {
                    bool isEmpty = true;
                    for (ScanResult result in snapshot.data) {
                      if (result.device.name.split('_')[0] == 'MODULE') {
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
                        if (r.device.name.split('_')[0] != 'MODULE')
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
    );
  }
}
