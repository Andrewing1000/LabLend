import 'package:flutter/widgets.dart';

class CustomScrollPhysics extends ScrollPhysics {
  final double scrollSpeedFactor;

  const CustomScrollPhysics({super.parent, this.scrollSpeedFactor = 1});

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor), scrollSpeedFactor: scrollSpeedFactor);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * scrollSpeedFactor;
  }
}