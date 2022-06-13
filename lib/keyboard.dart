import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef KeyboardTapCallback = void Function(String text);

@immutable
class KeyboardUIConfig {
  //Digits have a round thin borders, [digitBorderWidth] define their thickness
  final double digitBorderWidth;
  final TextStyle digitTextStyle;
  final TextStyle deleteButtonTextStyle;
  final Color primaryColor;
  final Color digitFillColor;
  final EdgeInsetsGeometry keyboardRowMargin;
  final EdgeInsetsGeometry digitInnerMargin;
  final EdgeInsetsGeometry keyboardRootMargin;
  final BoxDecoration? digitItemDecoration;

  //Size for the keyboard can be define and provided from the app.
  //If it will not be provided the size will be adjusted to a screen size.
  final Size? keyboardSize;

  //KeyboardItemWidget allows you to define your own style instead of using the [KeyboardDigit]
  final KeyboardItemWidget Function(String, KeyboardUIConfig, KeyboardTapCallback)? keyboardItemBuilder;

  const KeyboardUIConfig({
    this.digitBorderWidth = 1,
    this.keyboardRowMargin = const EdgeInsets.only(top: 15, left: 4, right: 4),
    this.keyboardRootMargin = const EdgeInsets.only(top: 16),
    this.digitInnerMargin = const EdgeInsets.all(24),
    this.primaryColor = Colors.white,
    this.digitFillColor = Colors.transparent,
    this.digitTextStyle = const TextStyle(fontSize: 30, color: Colors.white),
    this.deleteButtonTextStyle = const TextStyle(fontSize: 16, color: Colors.white),
    this.digitItemDecoration,
    this.keyboardSize,
    this.keyboardItemBuilder,
  });
}

class Keyboard extends StatelessWidget {
  final KeyboardUIConfig keyboardUIConfig;
  final KeyboardTapCallback onKeyboardTap;
  final _focusNode = FocusNode();
  static String deleteButton = 'keyboard_delete_button';

  //should have a proper order [1...9, 0]
  final List<String>? digits;

  Keyboard({
    Key? key,
    required this.keyboardUIConfig,
    required this.onKeyboardTap,
    this.digits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _buildKeyboard(context);

  Widget _buildKeyboard(BuildContext context) {
    List<String> keyboardItems = List.filled(10, '0');
    if (digits == null || digits!.isEmpty) {
      keyboardItems = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    } else {
      keyboardItems = digits!;
    }
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = screenSize.height > screenSize.width ? screenSize.height / 2 : screenSize.height - 80;
    final keyboardWidth = keyboardHeight * 3 / 4;
    final keyboardSize = this.keyboardUIConfig.keyboardSize != null ? this.keyboardUIConfig.keyboardSize! : Size(keyboardWidth, keyboardHeight);
    return Container(
      margin: this.keyboardUIConfig.keyboardRootMargin,
      child: SizedBox(
        width: keyboardSize.width + 16,
        height: keyboardSize.height + 16,
        child: RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: (event) {
            if (event is RawKeyUpEvent) {
              if (keyboardItems.contains(event.data.keyLabel)) {
                onKeyboardTap(event.logicalKey.keyLabel);
                return;
              }
              if (event.logicalKey.keyLabel == 'Backspace' || event.logicalKey.keyLabel == 'Delete') {
                onKeyboardTap(Keyboard.deleteButton);
                return;
              }
            }
          },
          child: AlignedGrid(
            keyboardSize: keyboardSize,
            children: List.generate(keyboardItems.length, (index) {
              if (keyboardUIConfig.keyboardItemBuilder != null) {
                return keyboardUIConfig.keyboardItemBuilder!(keyboardItems[index], keyboardUIConfig, onKeyboardTap);
              } else {
                return KeyboardDigit(
                  text: keyboardItems[index],
                  keyboardUIConfig: keyboardUIConfig,
                  onKeyboardTap: onKeyboardTap,
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}

class KeyboardDigit extends KeyboardItemWidget {
  final KeyboardUIConfig keyboardUIConfig;

  const KeyboardDigit({Key? key, required String text, required this.keyboardUIConfig, required Function(String) onKeyboardTap})
      : super(key: key, text: text, onKeyboardTap: onKeyboardTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
            onTap: () {
              onKeyboardTap(text);
            },
            child: Container(
              decoration: keyboardUIConfig.digitItemDecoration ??
                  BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: keyboardUIConfig.primaryColor,
                      width: keyboardUIConfig.digitBorderWidth,
                    ),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: keyboardUIConfig.digitFillColor,
                ),
                child: Center(
                  child: Text(
                    text,
                    style: keyboardUIConfig.digitTextStyle,
                    semanticsLabel: text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class KeyboardItemWidget extends StatelessWidget {
  final String text;
  final Function(String) onKeyboardTap;

  const KeyboardItemWidget({Key? key, required this.text, required this.onKeyboardTap}) : super(key: key);
}

class AlignedGrid extends StatelessWidget {
  final double runSpacing = 2;
  final double spacing = 2.0;
  final int listSize;
  final columns = 3;
  final rows = 4;
  final List<Widget> children;
  final Size keyboardSize;

  const AlignedGrid({Key? key, required this.children, required this.keyboardSize})
      : listSize = children.length,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final primarySize;
    final itemSize;
    if (keyboardSize.width > keyboardSize.height) {
      primarySize = keyboardSize.height;
      itemSize = primarySize / rows;
    } else {
      primarySize = keyboardSize.width;
      itemSize = primarySize / rows;
    }

    final numToItem = (item) => Container(
          margin: EdgeInsets.all(2),
          width: itemSize,
          height: itemSize,
          child: item,
        );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: children.sublist(0, 3).map(numToItem).toList(),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: children.sublist(3, 6).map(numToItem).toList(),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: children.sublist(6, 9).map(numToItem).toList(),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: children.sublist(9).map(numToItem).toList(),
        )
      ],
    );
  }
}
