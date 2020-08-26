import 'package:cult_connect/core/network/network_info.dart';
import 'package:cult_connect/features/modules/presentation/pages/sensor_datails_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';

import 'features/login/presentation/bloc/login_bloc.dart';
import 'features/login/presentation/pages/pages.dart';
import 'features/login/presentation/pages/tutorial_pages.dart';
import 'features/modules/presentation/bloc/bloc.dart';
import 'features/modules/presentation/pages/bluetooth_device_page.dart';
import 'features/modules/presentation/pages/bluetooth_find_devices_page.dart';
import 'features/modules/presentation/pages/bluetooth_off_page.dart';
import 'features/modules/presentation/pages/bluetooth_page.dart';
import 'features/modules/presentation/pages/dashboard_pages.dart';
import 'injection_container.dart';

class RouteGenerator {
  Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<LoginBloc>(),
            child: LoginPage(
              data: args,
            ),
          ),
        );
      case '/forgotPasswordFirstPage':
        // Validation of correct data type
        // if (args is String) {
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordFirstPage(
            data: args,
          ),
        );
      // }
      case '/forgotPasswordSecondPage':
        // Validation of correct data type
        // if (args is String) {
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordSecondPage(
            data: args,
          ),
        );
      // }
      case '/tutorialPages':
        return MaterialPageRoute(
          builder: (_) => TutorialPages(
            data: args,
          ),
        );
      case '/tutorialFirstPage':
        return MaterialPageRoute(
          builder: (_) => TutorialFirstPage(
            data: args,
          ),
        );
      case '/bluetoothPage':
        return MaterialPageRoute(
          builder: (_) => BluetoothPage(
            data: args,
          ),
        );
      case '/bluetoothFindDevicesPage':
        return MaterialPageRoute(
          builder: (_) => BluetoothFindDevicesPage(
            data: args,
          ),
        );
      case '/bluetoothOffPage':
        return MaterialPageRoute(
          builder: (_) => BluetoothOffPage(
            state: args,
          ),
        );
      case '/bluetoothDevicePage':
        return MaterialPageRoute(
          builder: (_) => DeviceScreen(
            device: args,
          ),
        );
      case '/dashboardPages':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<ModuleBloc>(),
            child: BlocProvider.value(
              value: sl<LoginBloc>(),
              child: DashboardPages(
                data: args,
              ),
            ),
          ),
        );
      case '/sensorDetailsPage':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<ModuleBloc>(),
            child: SensorDetailsPage(
              data: args,
            ),
          ),
        );
      // If args is not of the correct type, return an error page.
      // You can also throw an exception while in development.
      // return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
