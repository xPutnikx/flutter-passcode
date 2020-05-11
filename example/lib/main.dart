import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
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
      home: ExampleHomePage(title: 'Passcode Lock Screen Example'),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  ExampleHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  bool isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You are ${isAuthenticated ? '' : 'NOT'} authenticated'),
            _defaultLockScreenButton(context),
            _customColorsLockScreenButton(context)
          ],
        ),
      ),
    );
  }

  _defaultLockScreenButton(BuildContext context) => MaterialButton(
        color: Theme.of(context).primaryColor,
        child: Text('Open Default Lock Screen'),
        onPressed: () {
          _showLockScreen(context, opaque: false);
        },
      );

  _customColorsLockScreenButton(BuildContext context) => MaterialButton(
        color: Theme.of(context).primaryColor,
        child: Text('Open Custom Lock Screen'),
        onPressed: () {
          _showLockScreen(context,
              opaque: false,
              circleUIConfig: CircleUIConfig(borderColor: Colors.blue, fillColor: Colors.blue, circleSize: 30),
              keyboardUIConfig: KeyboardUIConfig(digitBorderWidth: 2, primaryColor: Colors.blue));
        },
      );

  _showLockScreen(BuildContext context,
      {bool opaque, CircleUIConfig circleUIConfig, KeyboardUIConfig keyboardUIConfig}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
            title: Text(
              'Enter App Passcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 45),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelLocalizedText: 'Cancel',
            deleteLocalizedText: 'Delete',
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = '123456' == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
    }
  }

  _onPasscodeCancelled() {}

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }
}
