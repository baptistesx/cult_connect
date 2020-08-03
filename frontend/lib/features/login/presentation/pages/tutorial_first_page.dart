import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TutorialFirstPage extends StatelessWidget {
  dynamic data;

  TutorialFirstPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 60),
              Text(
                'Welcome to',
                style: TextStyle(
                  fontFamily: 'Somatic',
                  color: Colors.white,
                  fontSize: 50,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Image.asset(
                'assets/images/logo_nom_blanc.png',
                scale: 1.2,
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
