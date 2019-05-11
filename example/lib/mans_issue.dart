import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passcode_screen/passcode_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passcode Lock Screen Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PassCodePage(),
      routes: <String, WidgetBuilder>{
        "/roadmappage": (context) => SecondWidget(),
      },
    );
  }
}

class PassCodePage extends StatefulWidget {
  PassCodePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _PassCodePageState();
}

class _PassCodePageState extends State<PassCodePage> {
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MaterialButton(
            onPressed: () => Navigator.push(
                context,
                PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
                          title: 'Enter App Passcode',
                          passwordEnteredCallback: _onPasscodeEntered,
                          isValidCallback: _authenticationPassed,
                          cancelLocalizedText: 'Cancel',
                          deleteLocalizedText: 'Delete',
                          shouldTriggerVerification: _verificationNotifier.stream,
                        ))),
            child: Container(margin: EdgeInsets.all(32.0), child: Text("Login"))));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = '123456' == enteredPasscode;
    if (isValid) {
      _verificationNotifier.add(isValid);
    }
  }

  _authenticationPassed() {
    Navigator.pushNamedAndRemoveUntil(context, '/roadmappage', (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }
}

class SecondWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(margin: EdgeInsets.all(32.0), child: Text("My seconds page")),
    );
  }
}
