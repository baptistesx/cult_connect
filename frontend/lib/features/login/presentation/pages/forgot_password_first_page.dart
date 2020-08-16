import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../widgets/forgot_password_first_form.dart';

class ForgotPasswordFirstPage extends StatelessWidget {
  dynamic data;

  ForgotPasswordFirstPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<LoginBloc>(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: IconButton(
                        iconSize: 45,
                        icon: Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/images/logo.png',
                      scale: 1.4,
                    ),
                    const Spacer(flex: 2)
                  ],
                ),
                Image.asset(
                  'assets/images/logo_nom_fonce.png',
                  scale: 1.8,
                ),
                Text(
                  "Let's set a new password ...",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ForgotPasswordFirstForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
