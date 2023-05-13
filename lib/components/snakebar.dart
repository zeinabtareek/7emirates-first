import 'package:flutter/material.dart';

class SnakeBarUtils {
  static void showSnack(final _scaffoldKey, String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  static void ErrorNew(final BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // @Deprecated('Use [ErrorNew] Instead')
  static void Error(final GlobalKey<ScaffoldMessengerState> _scaffoldKey, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  static void Success(final _scaffoldKey, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
