library passcode_screen;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/shake_curve.dart';

typedef PasswordEnteredCallback = void Function(String text);
typedef IsValidCallback = void Function();
typedef CancelCallback = void Function();

class PasscodeScreen extends StatefulWidget {
  final Widget? title;
  final Widget? subtitle;
  final int passwordDigits;
  final PasswordEnteredCallback passwordEnteredCallback;
  // Cancel button and delete button will be switched based on the screen state
  final Widget? cancelButton;
  final Widget? deleteButton;
  final Stream<bool> shouldTriggerVerification;
  final CircleUIConfig circleUIConfig;
  final KeyboardUIConfig keyboardUIConfig;

  //isValidCallback will be invoked after passcode screen will pop.
  final IsValidCallback? isValidCallback;
  final CancelCallback? cancelCallback;

  final Color? backgroundColor;
  final Widget? bottomWidget;
  final List<String>? digits;

  PasscodeScreen({
    Key? key,
    this.title,
    this.subtitle,
    this.passwordDigits = 6,
    required this.passwordEnteredCallback,
    this.cancelButton,
    this.deleteButton,
    required this.shouldTriggerVerification,
    this.isValidCallback,
    CircleUIConfig? circleUIConfig,
    KeyboardUIConfig? keyboardUIConfig,
    this.bottomWidget,
    this.backgroundColor,
    this.cancelCallback,
    this.digits,
  })  : circleUIConfig = circleUIConfig ?? const CircleUIConfig(),
        keyboardUIConfig = keyboardUIConfig ?? const KeyboardUIConfig(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> with SingleTickerProviderStateMixin {
  late StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';
  late AnimationController controller;
  late Animation<double> animation;

  @override
  initState() {
    super.initState();
    streamSubscription = widget.shouldTriggerVerification.listen((isValid) => _showValidation(isValid));
    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation curve = CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve as Animation<double>)
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black.withOpacity(0.8),
      body: SafeArea(
        child: isPortrait ? _buildPortraitPasscodeScreen() : _buildLandscapePasscodeScreen(),
      ),
    );
  }

  _buildPortraitPasscodeScreen() => Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.title ?? Container(),
              Container(
                margin: const EdgeInsets.only(top: 20),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildCircles(),
                ),
              ),
              widget.subtitle ?? Container(),
              _buildKeyboardPortrait(),
            ],
          ),
          Positioned(child: widget.bottomWidget ?? Container()),
          Positioned(
            child: Align(
              alignment: Alignment.bottomRight,
              child: _buildDeleteButton(),
            ),
          ),
        ],
      );

  _buildLandscapePasscodeScreen() => Stack(
        children: [
          Positioned(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  widget.title ?? Container(),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _buildCircles(),
                                    ),
                                  ),
                                  widget.subtitle ?? Container(),
                                ],
                              ),
                            ),
                          ),
                          widget.bottomWidget != null ? widget.bottomWidget! : Container()
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildKeyboardLandscape(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomRight,
              child: _buildDeleteButton(),
            ),
          )
        ],
      );

  _buildKeyboardPortrait() => Expanded(
        flex: 1,
        child: Keyboard(
          onKeyboardTap: _onKeyboardButtonPressed,
          keyboardUIConfig: widget.keyboardUIConfig,
          digits: widget.digits,
        ),
      );

  _buildKeyboardLandscape() => Container(
        child: Keyboard(
          onKeyboardTap: _onKeyboardButtonPressed,
          keyboardUIConfig: widget.keyboardUIConfig,
          digits: widget.digits,
        ),
      );

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig;
    var extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      final isFilled = i < enteredPasscode.length;
      list.add(
        Container(
          margin: EdgeInsets.all(8),
          child: widget.circleUIConfig.indicatorBuilder != null
              ? widget.circleUIConfig.indicatorBuilder!(isFilled, extraSize)
              : Circle(
                  filled: isFilled,
                  circleUIConfig: config,
                  extraSize: extraSize,
                ),
        ),
      );
    }
    return list;
  }

  _onDeleteCancelButtonPressed() {
    if (enteredPasscode.length > 0) {
      setState(() {
        enteredPasscode = enteredPasscode.substring(0, enteredPasscode.length - 1);
      });
    } else {
      if (widget.cancelCallback != null && widget.deleteButton != null && widget.cancelButton != null) {
        widget.cancelCallback!();
      }
    }
  }

  _onCancelButtonPressed() {
    setState(() {
      enteredPasscode = '';
    });
    if (widget.cancelCallback != null) {
      widget.cancelCallback!();
    }
  }

  _onKeyboardButtonPressed(String text) {
    if (text == Keyboard.deleteButton) {
      _onDeleteCancelButtonPressed();
      return;
    }
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
      widget.isValidCallback!();
    } else {
      print("You didn't implement validation callback. Please handle a state by yourself then.");
    }
  }

  Widget _buildDeleteButton() {
    if (widget.deleteButton != null && widget.cancelButton != null) {
      return Container(
        child: CupertinoButton(
          onPressed: _onDeleteCancelButtonPressed,
          child: Container(
            margin: widget.keyboardUIConfig.digitInnerMargin,
            child: enteredPasscode.length == 0 ? widget.cancelButton : widget.deleteButton,
          ),
        ),
      );
    } else if (widget.deleteButton != null) {
      return Container(
        child: CupertinoButton(
          onPressed: _onDeleteCancelButtonPressed,
          child: Container(
            margin: widget.keyboardUIConfig.digitInnerMargin,
            child: widget.deleteButton,
          ),
        ),
      );
    } else if (widget.cancelButton != null) {
      return Container(
        child: CupertinoButton(
          onPressed: _onCancelButtonPressed,
          child: Container(
            margin: widget.keyboardUIConfig.digitInnerMargin,
            child: widget.cancelButton,
          ),
        ),
      );
    }
    return Container();
  }
}
