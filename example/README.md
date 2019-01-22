# Example

<img src="https://github.com/xPutnikx/flutter-passcode/blob/master/example/passcode-screen-demo.gif?raw=true" alt="passcode-screen-demo.gif" width="300">

1. Create a beautiful passcode lock view simply.

```dart
PasscodeScreen(
  title: title,
  passwordEnteredCallback: _onPasscodeEntered,
  cancelLocalizedText: 'Cancel',
  deleteLocalizedText: 'Delete',
  shouldTriggerVerification: _verificationNotifier.stream,  
);
```

2. Passcode input completed callback.
```dart
_onPasscodeEntered(String enteredPasscode) {
  
}
```

3. Notify passcode screen if passcode correct or not 
```dart
final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

_onPasscodeEntered(String enteredPasscode) {
  bool isValid = '123456' == enteredPassword;
  _verificationNotifier.add(isValid);
}

```

Don't forget to close a stream
```dart
@override
void dispose() {
  _verificationNotifier.close();
  super.dispose();
}

```

4. Customize UI.

Customize circles
```dart
class CircleUIConfig {
  final Color borderColor;
  final Color fillColor;
  final double borderWidth;
  final double circleSize;
  double extraSize;
}
```

Customize keyboard
```dart
class KeyboardUIConfig {
  final double digitSize;
  final TextStyle digitTextStyle;
  final TextStyle deleteButtonTextStyle;
  final Color primaryColor;
  final Color digitFillColor;
  final EdgeInsetsGeometry keyboardRowMargin;
  final EdgeInsetsGeometry deleteButtonMargin;
}
```

<img src="https://github.com/xPutnikx/flutter-passcode/blob/master/example/passcode-screen-custom.png?raw=true" alt="passcode-screen-custom.png" width="300">
