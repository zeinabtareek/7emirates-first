import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class ToastUtils{



  static void showSnack(final _scaffoldKey ,String message) {

    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);



  }

  static void Error(final _scaffoldKey ,String message) {


    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0
    );

  }



  static void Success(final _scaffoldKey ,String message) {

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: TheamPrimary,
        textColor: Colors.white,
        fontSize: 15.0
    );

  }
}