import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../../domain/entities/module.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../pages/sensor_datails_page.dart';

abstract class ModuleEvent extends Equatable {
  ModuleEvent([List props = const <dynamic>[]]) : super(props);
}

class LaunchAddModule extends ModuleEvent {
  final AddModuleParams addModuleParams;

  LaunchAddModule(this.addModuleParams) : super([addModuleParams]);
}

class LaunchRemoveFavouriteSensorById extends ModuleEvent {
  final String sensorId;

  LaunchRemoveFavouriteSensorById(this.sensorId) : super([sensorId]);
}

class LaunchAddFavouriteSensorById extends ModuleEvent {
  final String sensorId;

  LaunchAddFavouriteSensorById(this.sensorId) : super([sensorId]);
}

class LaunchRouterIdsError extends ModuleEvent {
  LaunchRouterIdsError() : super([]);
}

class LaunchWifiConfiguration extends ModuleEvent {
  final WifiParams wifiParams;

  LaunchWifiConfiguration(this.wifiParams) : super([wifiParams]);
}

class LaunchSendRouterIds2Module extends ModuleEvent {
  final BluetoothCharacteristic characteristic;
  final List<int> val2Send;
  final AddModuleParams addModuleParams;

  LaunchSendRouterIds2Module(
      this.characteristic, this.val2Send, this.addModuleParams)
      : super([characteristic, val2Send, addModuleParams]);
}

class LaunchUpdateList extends ModuleEvent {
  LaunchUpdateList() : super([]);
}

class LaunchShowSensorSettings extends ModuleEvent {
  bool showSettings;
  LaunchShowSensorSettings(this.showSettings) : super([showSettings]);
}

class LaunchShowModuleSettings extends ModuleEvent {
  bool showSettings;
  LaunchShowModuleSettings(this.showSettings) : super([showSettings]);
}

class LaunchUpdateSensorSettings extends ModuleEvent {
  UpdateSensorParams updateSensorParams;

  LaunchUpdateSensorSettings(this.updateSensorParams)
      : super([updateSensorParams]);
}

class LaunchUpdateModuleSettings extends ModuleEvent {
  UpdateModuleParams updateModuleParams;

  LaunchUpdateModuleSettings(this.updateModuleParams)
      : super([updateModuleParams]);
}
