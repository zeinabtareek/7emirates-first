import 'package:flutter/material.dart';

class NoneOpenScreen extends PageRouteBuilder {
  final Widget widget;
  NoneOpenScreen({required this.widget})
      : super(pageBuilder: (BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return widget;
  }, transitionsBuilder: (BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child;
  }
  );

}
