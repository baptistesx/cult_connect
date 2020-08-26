import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../widgets/add_module_form.dart';
import 'bluetooth_off_page.dart';

class DeviceScreen extends StatelessWidget {
  List<BluetoothService> servicesList;
  final BluetoothDevice device;
  bool wasConnectedBefore;

  DeviceScreen({
    Key key,
    this.device,
  })  : wasConnectedBefore = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await device.disconnect();
        Navigator.pop(context);
      },
      child: BlocProvider(
        create: (context) => sl<ModuleBloc>(),
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;
                if (state == BluetoothState.on && wasConnectedBefore == false) {
                  wasConnectedBefore = true;
                  return AddModuleForm(device: device);
                } else if (state == BluetoothState.on &&
                    wasConnectedBefore == true) {
                  device.disconnect();
                  Navigator.pop(context);
                  return Container();
                }
                return BluetoothOffPage(state: state);
              }),
        ),
      ),
    );
  }
}
