import 'package:flutter/material.dart';

import 'features/login/data/models/user_model.dart';
import 'injection_container.dart' as di;
import 'route_generator.dart';

UserModel globalUser = UserModel(
  userId: null,
  emailAddress: null,
  modules: null,
  favouriteSensors: null,
  routerPassword: null,
  routerSsid: null,
  token: null,
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initGlobal();
  await di.initLoginDI();
  await di.initModulesDI();
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
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
