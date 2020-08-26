import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothOffPage extends StatelessWidget {
  const BluetoothOffPage({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.bluetooth_disabled,
                    size: 200.0,
                    color: Colors.white54,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.\nPlease turn it ON (only while adding a module)',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .subtitle1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
