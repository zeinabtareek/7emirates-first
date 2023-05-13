import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/style_sheet.dart';

class MyTextFieldAnim extends StatefulWidget {
  TextEditingController ETcontroler = TextEditingController();

  IconData rightIcon;
  Color? rightIconColor;
  Color? containerColor;
  double? containerHeight;
  Color? textColor;
  Color? hintTextColor;
  Color? lableTextColor;
  Color? enableBorder;
  Color? focusBorder;
  String? hintText;
  bool verifyWarning;
  bool passwordtext;
  double borderRadius;
  TextInputType textType;
  TextInputAction textInputAction;
  double? fontSize;
  double? hintSize;
  double? lableSize;
  int maxLines;
  var textAlignment;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSummited;

  MyTextFieldAnim(
      {Key? key,
      required this.ETcontroler,
      required this.hintText,
      required this.verifyWarning,
      this.rightIcon = Icons.close,
      this.rightIconColor = Colors.blueGrey,
      this.hintTextColor = Colors.blueGrey,
      this.lableTextColor = Colors.blueGrey,
      this.textColor = Colors.black,
      this.containerColor = Colors.transparent,
      this.borderRadius = 5.0,
      this.fontSize = 15,
      this.passwordtext = false,
      this.containerHeight = 50,
      this.hintSize = 12,
      this.lableSize = 10,
      this.maxLines = 1,
      this.textAlignment = TextAlign.left,
      this.enableBorder = Colors.blueGrey,
      this.focusBorder = Colors.blueGrey,
      this.textInputAction = TextInputAction.newline,
      this.onChanged = null,
      this.onSummited = null,
      this.textType = TextInputType.text})
      : super(key: key);

  @override
  _MyTextFieldAnimState createState() => _MyTextFieldAnimState();
}

class _MyTextFieldAnimState extends State<MyTextFieldAnim> {
  bool ttext = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: widget.containerHeight,
      width: MediaQuery.of(context).size.width,
      child: TextField(
        controller: widget.ETcontroler,
        keyboardType: TextInputType.multiline,
        obscureText: widget.passwordtext,
        textCapitalization: TextCapitalization.sentences,
        textAlign: widget.textAlignment,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.hintText,

          prefix: widget.verifyWarning
              ? Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: widget.fontSize,
                )
              : null,
          //  hintText: widget.hintText.toString(),
          hintStyle: ts_Regular(widget.hintSize, widget.hintTextColor),
          labelStyle: ts_Regular(widget.hintSize, widget.hintTextColor),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.enableBorder!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.focusBorder!),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.focusBorder!),
          ),
        ),
        style: ts_Regular(widget.fontSize, widget.textColor),
        textInputAction: widget.textInputAction,
        onChanged: (text) {
          setState(() {
            if (widget.ETcontroler.text.length > 0) {
              ttext = true;
            } else {
              ttext = false;
            }
          });
          widget.onChanged!(text);
        },
        onSubmitted: (newValue) {
          setState(() {
            widget.onSummited!(newValue);
          });
        },
      ),
    );
  }
}
