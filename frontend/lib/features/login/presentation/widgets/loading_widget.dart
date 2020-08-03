import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  Color color;

  LoadingWidget({
    @required this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(color)),
      ),
    );
  }
}
