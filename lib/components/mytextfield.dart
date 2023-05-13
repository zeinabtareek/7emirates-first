import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/style_sheet.dart';

class MyTextField extends StatefulWidget {
  TextEditingController ETcontroler = TextEditingController();

  IconData? rightIcon;
  Color rightIconColor;
  Color containerColor;
  double? containerHeight;
  Color textColor;
  Color hintTextColor;
  String? hintText;
  bool? verifyWarning;
  bool? passwordtext;
  double? borderRadius;
  TextInputType textType;
  TextInputAction textInputAction;
  double fontSize;
  double hintSize;
  int maxLines;
  var textAlignment;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSummited;

  MyTextField(
      {Key? key,
      required this.ETcontroler,
      required this.hintText,
      required this.verifyWarning,
      this.rightIcon = Icons.close,
      this.rightIconColor = Colors.blueGrey,
      this.hintTextColor = Colors.blueGrey,
      this.textColor = Colors.black,
      this.containerColor = Colors.transparent,
      this.borderRadius = 5.0,
      this.fontSize = 15,
      this.passwordtext = false,
      this.containerHeight = 50,
      this.hintSize = 12,
      this.maxLines = 1,
      this.textAlignment = TextAlign.left,
      this.textInputAction = TextInputAction.newline,
      this.onChanged = null,
      this.onSummited = null,
      this.textType = TextInputType.text})
      : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool ttext = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.containerColor,
        borderRadius: BorderRadius.circular(widget.borderRadius!),
      ),
      padding: EdgeInsets.fromLTRB(20, 2, 0, 2),
      alignment: Alignment.center,
      height: widget.containerHeight,
      width: MediaQuery.of(context).size.width,
      child: TextField(
        controller: widget.ETcontroler,
        keyboardType: TextInputType.multiline,
        obscureText: widget.passwordtext!,
        textCapitalization: TextCapitalization.sentences,
        textAlign: widget.textAlignment,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          suffixIcon: ttext
              ? GestureDetector(
                  child: Icon(
                    Icons.clear,
                    color: widget.rightIconColor,
                    size: widget.fontSize + 3,
                  ),
                  onTap: () {
                    setState(() {
                      widget.ETcontroler.clear();
                      ttext = false;
                    });
                  },
                )
              : Icon(
                  widget.rightIcon,
                  color: widget.rightIconColor,
                ),
          prefix: widget.verifyWarning!
              ? Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: widget.fontSize,
                )
              : null,
          hintText: widget.hintText.toString(),
          //  contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 5),
          hintStyle: ts_Regular(widget.hintSize, widget.hintTextColor),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
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
