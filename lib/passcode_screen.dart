library passcode_screen;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/shake_curve.dart';

typedef PasswordEnteredCallback = void Function(String text);
typedef IsValidCallback = void Function();
typedef CancelCallback = void Function();

class PasscodeScreen extends StatefulWidget {
  final String title;
  final bool shouldShowCancelButton;
  final int passwordDigits;
  final Color titleColor;
  final Color backgroundColor;
  final PasswordEnteredCallback passwordEnteredCallback;

  //isValidCallback will be invoked after passcode screen will pop.
  final IsValidCallback isValidCallback;
  final CancelCallback cancelCallback;
  final String cancelLocalizedText;
  final String deleteLocalizedText;
  final Stream<bool> shouldTriggerVerification;
  final Widget bottomWidget;
  final CircleUIConfig circleUIConfig;
  final KeyboardUIConfig keyboardUIConfig;

  PasscodeScreen({
    Key key,
    @required this.title,
    this.shouldShowCancelButton = true,
    this.passwordDigits = 6,
    @required this.passwordEnteredCallback,
    @required this.cancelLocalizedText,
    @required this.deleteLocalizedText,
    @required this.shouldTriggerVerification,
    this.isValidCallback,
    this.circleUIConfig,
    this.keyboardUIConfig,
    this.bottomWidget,
    this.titleColor = Colors.white,
    this.backgroundColor,
    this.cancelCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';
  AnimationController controller;
  Animation<double> animation;

  @override
  initState() {
    super.initState();
    streamSubscription = widget.shouldTriggerVerification.listen((isValid) => _showValidation(isValid));
    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation curve = CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            enteredPasscode = '';
            controller.value = 0;
          });
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black.withOpacity(0.8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: widget.titleColor, fontWeight: FontWeight.w300),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, left: 60, right: 60),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildCircles(),
              ),
            ),
            IntrinsicHeight(
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Keyboard(
                  onDeleteCancelTap: _onDeleteCancelButtonPressed,
                  onKeyboardTap: _onKeyboardButtonPressed,
                  shouldShowCancel: widget.shouldShowCancelButton && enteredPasscode.length == 0,
                  cancelLocalizedText: widget.cancelLocalizedText,
                  deleteLocalizedText: widget.deleteLocalizedText,
                  keyboardUIConfig: widget.keyboardUIConfig != null ? widget.keyboardUIConfig : KeyboardUIConfig(),
                ),
              ),
            ),
            widget.bottomWidget != null ? widget.bottomWidget : Container()
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig != null ? widget.circleUIConfig : CircleUIConfig();
    config.extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(Circle(
        filled: i < enteredPasscode.length,
        circleUIConfig: config,
      ));
    }
    return list;
  }

  _onDeleteCancelButtonPressed() {
    if (enteredPasscode.length > 0) {
      setState(() {
        enteredPasscode = enteredPasscode.substring(0, enteredPasscode.length - 1);
      });
    } else {
      if (widget.shouldShowCancelButton) {
        Navigator.maybePop(context);
      }

      if (widget.cancelCallback != null) {
        widget.cancelCallback();
      }
    }
  }

  _onKeyboardButtonPressed(String text) {
    setState(() {
      if (enteredPasscode.length < widget.passwordDigits) {
        enteredPasscode += text;
        if (enteredPasscode.length == widget.passwordDigits) {
          widget.passwordEnteredCallback(enteredPasscode);
        }
      }
    });
  }

  @override
  didUpdateWidget(PasscodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification.listen((isValid) => _showValidation(isValid));
    }
  }

  @override
  dispose() {
    controller.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  _showValidation(bool isValid) {
    if (isValid) {
      Navigator.maybePop(context).then((pop) => _validationCallback());
    } else {
      controller.forward();
    }
  }

  _validationCallback() {
    if (widget.isValidCallback != null) {
      widget.isValidCallback();
    } else {
      print("You didn't implement validation callback. Please handle a state by yourself then.");
    }
  }
}
