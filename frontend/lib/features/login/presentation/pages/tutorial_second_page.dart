import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TutorialSecondPage extends StatelessWidget {
  dynamic data;

  TutorialSecondPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/tuto1.png',
                  scale: 1.2,
                ),
                SizedBox(height: 50),
                Text(
                  'All your modules will be connected to your wifi network to access Internet',
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
      ),
    );
  }
}
