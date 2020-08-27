import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) => Text(
        "MODULE_"+result.device.name.substring(2,7),
        style: TextStyle(color: Colors.white),
      );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      trailing: RaisedButton(
        child: Text(
          'Add',
        ),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
    );
  }
}
