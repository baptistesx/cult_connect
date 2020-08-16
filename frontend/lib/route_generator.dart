import 'package:flutter/material.dart';

import 'features/login/presentation/pages/pages.dart';
import 'features/login/presentation/pages/tutorial_pages.dart';
import 'features/modules/presentation/pages/bluetooth_device_page.dart';
import 'features/modules/presentation/pages/bluetooth_find_devices_page.dart';
import 'features/modules/presentation/pages/bluetooth_off_page.dart';
import 'features/modules/presentation/pages/bluetooth_page.dart';
import 'features/modules/presentation/pages/dashboard_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
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
      case '/dashboardPage':
        return MaterialPageRoute(
          builder: (_) => DashboardPage(
            data: args,
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
