import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TutorialThirdPage extends StatelessWidget {
  dynamic data;

  TutorialThirdPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/tuto2.png',
                scale: 3.5,
              ),
              SizedBox(height: 50),
              Text(
                'A module is a box composed of different sensors and actuators',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
