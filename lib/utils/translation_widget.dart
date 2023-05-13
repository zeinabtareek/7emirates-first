import 'dart:developer';

import 'package:flutter/material.dart';
import 'translation_api.dart';
import 'app_settings.dart';

class TranslationWidget extends StatefulWidget {
  final String message;
  final TextStyle style;
  final int maxLines;

  final TextOverflow overflow;
  final bool softWrap;
  final TextAlign textAlign;

  const TranslationWidget({
    required this.message,
    required this.style,
    this.maxLines = 1000,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.textAlign = TextAlign.start,
    Key? key,
  }) : super(key: key);

  @override
  _TranslationWidgetState createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  String? translation;

  @override
  Widget build(BuildContext context) {
    if (cur_Lang_code == 'en') {
      return Text(widget.message.toString(),
          style: widget.style,
          maxLines: (widget.maxLines == 0) ? null : widget.maxLines,
          softWrap: widget.softWrap,
          overflow: widget.overflow,
          textAlign: (widget.textAlign != null) ? widget.textAlign : null);
    } else {
      return FutureBuilder(
        future: TranslationApi.translate(widget.message, cur_Lang_code),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          log('${snapshot.data}', name: 'error');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return buildWaiting();
            default:
              if (snapshot.hasError) {
                log('error ${snapshot.error.toString()}');
                translation = 'Could not translate, Api error';
              } else {
                translation = snapshot.data;
              }
              return Text(
                translation!,
                style: widget.style,
                maxLines: (widget.maxLines == 0) ? null : widget.maxLines,
                softWrap: widget.softWrap,
                overflow: widget.overflow,
                textAlign: (widget.textAlign != null) ? widget.textAlign : null,
              );
          }
        },
      );
    }
  }

  Widget buildWaiting() => translation == null
      ? Container()
      : Text(
          translation!,
          style: widget.style,
        );
}
