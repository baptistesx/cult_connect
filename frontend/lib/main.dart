// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'features/login/data/models/user_model.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// void main() => runApp(ChartApp());

// class ChartApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chart Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Syncfusion Flutter chart'),
//         ),
//         body: SfCartesianChart(
//             primaryXAxis: CategoryAxis(),
//             // Chart title
//             title: ChartTitle(text: 'Half yearly sales analysis'),
//             // Enable legend
//             legend: Legend(isVisible: true),
//             // Enable tooltip
//             tooltipBehavior: TooltipBehavior(enable: true),
//             series: <LineSeries<SalesData, String>>[
//               LineSeries<SalesData, String>(
//                   dataSource: <SalesData>[
//                     SalesData('Jan', 35),
//                     SalesData('Feb', 28),
//                     SalesData('Mar', 34),
//                     SalesData('Apr', 32),
//                     SalesData('May', 40)
//                   ],
//                   xValueMapper: (SalesData sales, _) => sales.year,
//                   yValueMapper: (SalesData sales, _) => sales.sales,
//                   // Enable data label
//                   dataLabelSettings: DataLabelSettings(isVisible: false)
//               )
//             ]
//         )
//     );
//   }
// }

// class SalesData {
//   SalesData(this.year, this.sales);

//   final String year;
//   final double sales;
// }


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'features/login/data/models/user_model.dart';
import 'injection_container.dart' as di;
import 'route_generator.dart';

final storage = FlutterSecureStorage();

UserModel globalUser = UserModel(
  emailAddress: "",
  modules: List(),
  favouriteSensors: [],
  routerPassword: "",
  routerSsid: "",
);

String jwt;

Future<String> get jwtOrEmpty async {
  var jwtToReturn = await storage.read(key: "jwt");
  if (jwtToReturn == null) return "";
  return jwtToReturn;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initGlobal();
  await di.initLoginDI();
  await di.initModulesDI();
  // await storage.write(key: "jwt", value: "");
  jwt = await jwtOrEmpty;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cult\'Connect',
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.light,
        primaryColor: const Color(0xFF456365),
        accentColor: const Color(0xFF8ab3a1),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        // Define the default font family.
        fontFamily: 'Roboto',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF274344)),
          headline2: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000)),
          button: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000)),
          headline4: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF000000)),
          headline3: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF)),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator().generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
