import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../../../../main.dart';
import '../../../login/presentation/widgets/loading_widget.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../bloc/bloc.dart';

class AddModuleForm extends StatelessWidget {
  String publicId;
  BluetoothDevice device;

  AddModuleForm({@required this.device}) : publicId = device.name.split('_')[1];

  final privateIdController = TextEditingController();
  final nameController = TextEditingController();
  final placeController = TextEditingController();
  final _addModuleFormKey = GlobalKey<FormState>();

  final routerSsidController = TextEditingController(
      text: globalUser.routerSsid.isEmpty ? "" : globalUser.routerSsid);
  final routerPasswordController = TextEditingController(
      text: globalUser.routerPassword.isEmpty ? "" : globalUser.routerPassword);

  WifiParams wifiParams = WifiParams(
      routerSsid: globalUser.routerSsid.isEmpty ? "" : globalUser.routerSsid,
      routerPassword:
          globalUser.routerPassword.isEmpty ? "" : globalUser.routerPassword);

  AddModuleParams addModuleParams = AddModuleParams(
    publicId: "",
    privateId: "",
    name: "",
    place: "",
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModuleBloc, ModuleState>(
      listener: (context, state) async {
        if (state is Error) {
          final snackBar = SnackBar(
            content: Row(children: [
              Icon(Icons.warning),
              SizedBox(
                width: 10,
              ),
              Text(state.message),
            ]),
            backgroundColor: Colors.red,
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else if (state is Loaded) {
          device.disconnect();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (!(state is Loaded)) {
          return StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                if (snapshot.data.isEmpty)
                  return Text("Bluetooth connection error");

                BluetoothService service =
                    snapshot.data[snapshot.data.length - 1];
                BluetoothCharacteristic characteristic =
                    service.characteristics[0];

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: IconButton(
                                iconSize: 45,
                                icon: Icon(
                                  Icons.keyboard_arrow_left,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  await device.disconnect();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const Spacer(),
                            Text("Router IDs",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center),
                            const Spacer(flex: 2)
                          ],
                        ),
                        Form(
                          key: _addModuleFormKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: routerSsidController,
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label_important),
                                  hintText: 'SSID',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  wifiParams.routerSsid = value;
                                },
                                validator: (String routerSsid) {
                                  if (routerSsid.isEmpty)
                                    return 'Please fill in the router ssid';
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: routerPasswordController,
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock),
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  wifiParams.routerPassword = value;
                                },
                                validator: (String routerPassword) {
                                  if (routerPassword.isEmpty)
                                    return 'Please fill in the password';
                                  return null;
                                },
                              ),
                              SizedBox(height: 30),
                              Text(device.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  )),
                              SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                controller: privateIdController,
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label_important),
                                  hintText: 'Private Id',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  addModuleParams.privateId = value;
                                  print(addModuleParams.privateId);
                                },
                                validator: (String privateId) {
                                  if (privateId.isEmpty)
                                    return EMPTY_PRIVATE_ID_FAILURE_MESSAGE;
                                  if (privateId.length != 3)
                                    return INVALID_PRIVATE_ID_FAILURE_MESSAGE;
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label),
                                  hintText: 'NickName',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  addModuleParams.name = value;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: placeController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.place),
                                  hintText: 'Place',
                                  // labelText: 'Place',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  addModuleParams.place = value;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              BlocBuilder<ModuleBloc, ModuleState>(
                                builder: (context, state) {
                                  print(state);
                                  if (state is Empty ||
                                      state == null ||
                                      state is Error) {
                                    return Row(
                                      children: [
                                        const Spacer(),
                                        FlatButton(
                                          onPressed: () async {
                                            if (_addModuleFormKey.currentState
                                                .validate()) {
                                              List<int> val2Send =
                                                  _getIdsInListOfInt();
                                              print(val2Send);
                                              dispatchSendRouterIds2Module(
                                                  context,
                                                  characteristic,
                                                  val2Send);
                                            }
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Go',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  if (state is Loading) {
                                    return Row(
                                      children: [
                                        const Spacer(),
                                        Expanded(
                                            child: LoadingWidget(
                                          color: Colors.white,
                                        )),
                                        FlatButton(
                                          onPressed: () async {
                                            if (_addModuleFormKey.currentState
                                                .validate()) {
                                              List<int> val2Send =
                                                  _getIdsInListOfInt();

                                              dispatchSendRouterIds2Module(
                                                  context,
                                                  characteristic,
                                                  val2Send);
                                            }
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Go',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container(
                                      width: 0.0,
                                      height: 0.0,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        }
        return Container();
      },
    );
  }

  void dispatchSendRouterIds2Module(BuildContext context,
      BluetoothCharacteristic characteristic, List<int> val2Send) {
    addModuleParams.publicId = publicId;
    BlocProvider.of<ModuleBloc>(context).add(
        LaunchSendRouterIds2Module(characteristic, val2Send, addModuleParams));
  }

  List<int> _getIdsInListOfInt() {
    List<int> valToSend = [];
    for (int i = 0; i < wifiParams.routerSsid.length; i++) {
      valToSend.add(wifiParams.routerSsid.codeUnitAt(i));
    }

    valToSend.add(';'.codeUnitAt(0));

    for (int i = 0; i < wifiParams.routerPassword.length; i++) {
      valToSend.add(wifiParams.routerPassword.codeUnitAt(i));
    }

    valToSend.add(';'.codeUnitAt(0));

    for (int i = 0; i < addModuleParams.privateId.length; i++) {
      valToSend.add(addModuleParams.privateId.codeUnitAt(i));
    }

    return valToSend;
  }
}
