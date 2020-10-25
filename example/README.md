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
  passwordDigits: 6,
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

## Landscape Support
<img src="https://github.com/xPutnikx/flutter-passcode/blob/master/example/passcode-screen-default-landscape.png?raw=true" alt="passcode-screen-default-lanscape.png" width="300">

## Relase notes:
### 1.0.0+1: 
Basic implementation of a widget.
- You could show a widget, enter passcode and validate it.

### 1.0.1
- Added `isValidCallback` to help you handle success scenario. `isValidCallback` will be invoked after passcode screen will pop.

### 1.0.2
- Added configurable background and title color.
- Added `cancelCallback` to react when user cancelled widget

### 1.1.0
- Provide widget instead of string for title
- Fixed digits layout
- Added flexibility to configure 'Cancel' and 'Delete' buttons as widgets
- Added flexibility to provide digits as list of strings for better customisation
- Removed navigation as default action when cancel pressed

### 1.1.1
- Add landscape view for the passcode screen

### 1.2.0
- Add dynamic size for landscape view.
- Moved 'Cancel' button to the bottom of the screen to align with iOS Native Passcode Screen style.

### 1.2.1
- Example updated to target Android 11
- Fixed [Issue#23](https://github.com/xPutnikx/flutter-passcode/issues/23)

## 1.2.2
- Fixed an issue with example build
- Example updated to show how to implement 'Reset passcode' feature