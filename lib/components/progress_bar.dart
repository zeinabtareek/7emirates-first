import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class MyProgressBar extends StatelessWidget {

  bool showProgress;
  MyProgressBar(this.showProgress, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Visibility(
      visible: showProgress,
      child: Container(
        color: Colors.black45,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment(0, 0),
        child:Container(
          padding: EdgeInsets.all(10),
          width: 90.0,
          height: 90.0,
          child: imageWidget(context),
        ),
      ),
    );
  }

  barWidget(BuildContext context) {
    return Material(
      elevation: 2,
      color: fc_bg,
      borderRadius: BorderRadius.circular(10),
      child:  Container(

        padding: EdgeInsets.all(10),
        width: 30.0,
        height: 30.0,
        child:  SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor:
              new AlwaysStoppedAnimation<Color>(TheamPrimary)),
        ),
      ),
    );
  }
  imageWidget(BuildContext context) {
    return Material(
      elevation: 2,
      color: fc_bg,
      borderRadius: BorderRadius.circular(10),
      child:  Container(

        padding: EdgeInsets.all(5),
        width: 90.0,
        height: 90.0,
        child:  Image.asset('assets/images/loadingico.gif'),
      ),
    );
  }
}
