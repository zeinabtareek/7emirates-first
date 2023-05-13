import 'package:flutter/material.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class MyProgressBarTrans extends StatelessWidget {

  bool showProgress;
  MyProgressBarTrans(this.showProgress, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Visibility(
      visible: showProgress,
      child: Container(
        color: Colors.black38,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment(0, 0),
        child:Container(
          padding: EdgeInsets.all(10),
          width: 60.0,
          height: 60.0,
          child: Material(
            elevation: 2,
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
          ),
        ),
      ),
    );
  }
}
