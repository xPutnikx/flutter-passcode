import 'package:flutter/material.dart';

@immutable
class CircleUIConfig {
  final Color borderColor;
  final Color fillColor;
  final double borderWidth;
  final double circleSize;

  //IndicatorWidget allows you to define your own style instead of using the [Cicle]
  final IndicatorWidget Function(bool, double)? indicatorBuilder;

  const CircleUIConfig({
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.fillColor = Colors.white,
    this.circleSize = 20,
    this.indicatorBuilder,
  });
}

class Circle extends IndicatorWidget {
  final CircleUIConfig circleUIConfig;

  Circle({
    Key? key,
    bool filled = false,
    required this.circleUIConfig,
    double extraSize = 0,
  }) : super(key: key, filled: filled, extraSize: extraSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: extraSize),
      width: circleUIConfig.circleSize,
      height: circleUIConfig.circleSize,
      decoration: BoxDecoration(
        color: filled ? circleUIConfig.fillColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: circleUIConfig.borderColor,
          width: circleUIConfig.borderWidth,
        ),
      ),
    );
  }
}

abstract class IndicatorWidget extends StatelessWidget {
  final bool filled;
  final double extraSize;

  const IndicatorWidget({Key? key, required this.filled, this.extraSize = 0}) : super(key: key);
}
